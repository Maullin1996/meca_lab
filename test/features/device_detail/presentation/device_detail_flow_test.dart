import 'dart:async';

import 'package:atomic_design/atoms/app_tokens.dart';
import 'package:atomic_design/config/atomic_design_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/features/device_detail/domain/repositories/sensor_history_repository.dart';
import 'package:meca_lab/features/device_detail/presentation/pages/device_detail_mobile_view.dart';
import 'package:meca_lab/features/device_detail/presentation/pages/device_detail_page.dart';
import 'package:meca_lab/features/device_detail/presentation/pages/device_detail_web_view.dart';
import 'package:meca_lab/features/device_detail/presentation/widgets/sensor_detail_card.dart';
import 'package:meca_lab/shared/data/repositories/device_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockDeviceRepository deviceRepository;
  late MockSensorHistoryRepository historyRepository;

  const mobileSize = Size(390, 844);
  const webSize = Size(1280, 800);

  final device = Device(
    id: 'dev-1',
    siteId: 'site-1',
    name: 'Compresor Norte',
    type: DeviceType.compresor,
    status: DeviceStatus.online,
    lastConnection: DateTime(2026, 7, 31, 10),
    sensorCount: 2,
    keySensors: const [],
  );

  final sensors = [
    const Sensor(
      id: 'sensor-1',
      deviceId: 'dev-1',
      name: 'Temperatura',
      type: SensorType.temperatura,
      unit: '°C',
      currentValue: 62,
      safeMin: 20,
      safeMax: 90,
    ),
    const Sensor(
      id: 'sensor-2',
      deviceId: 'dev-1',
      name: 'Presión',
      type: SensorType.presion,
      unit: 'bar',
      currentValue: 5.2,
      safeMin: 1,
      safeMax: 8,
    ),
  ];

  setUp(() async {
    deviceRepository = MockDeviceRepository();
    historyRepository = MockSensorHistoryRepository();
    when(
      () => historyRepository.watchSensorHistory(any()),
    ).thenAnswer((_) => const Stream.empty());
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        deviceRepositoryImplProvider.overrideWithValue(deviceRepository),
        sensorHistoryRepositoryImplProvider.overrideWithValue(
          historyRepository,
        ),
      ],
      child: const AppThemeProvider(
        child: MaterialApp(home: DeviceDetailPage(deviceId: 'dev-1')),
      ),
    );
  }

  Future<void> setSurfaceSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
  }

  testWidgets('ancho angosto renderiza DeviceDetailMobileView', (
    tester,
  ) async {
    when(
      () => deviceRepository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => const Stream.empty());

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(DeviceDetailMobileView), findsOneWidget);
    expect(find.byType(DeviceDetailWebView), findsNothing);
  });

  testWidgets('ancho ancho renderiza DeviceDetailWebView', (tester) async {
    when(
      () => deviceRepository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => const Stream.empty());

    await setSurfaceSize(tester, webSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(DeviceDetailWebView), findsOneWidget);
    expect(find.byType(DeviceDetailMobileView), findsNothing);
  });

  testWidgets('estado inicial (loading) muestra un indicador de carga', (
    tester,
  ) async {
    final controller = StreamController<Either<Failure, Device>>();
    addTearDown(controller.close);
    when(
      () => deviceRepository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => controller.stream);

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SensorDetailCard), findsNothing);
  });

  testWidgets('con datos muestra el nombre del device y una card por sensor', (
    tester,
  ) async {
    when(
      () => deviceRepository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => Stream.value(Right(device)));
    when(
      () => deviceRepository.getSensorsForDevice('dev-1'),
    ).thenAnswer((_) async => Right(sensors));

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Compresor Norte'), findsOneWidget);
    expect(find.byType(SensorDetailCard), findsNWidgets(2));
    expect(find.text('Alertas — próximamente'), findsOneWidget);
  });

  testWidgets('estado de error muestra el mensaje de reintento', (
    tester,
  ) async {
    when(() => deviceRepository.watchDeviceById('dev-1')).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('boom'))),
    );

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('No pudimos cargar el dispositivo'), findsOneWidget);
    expect(find.byType(SensorDetailCard), findsNothing);
  });
}
