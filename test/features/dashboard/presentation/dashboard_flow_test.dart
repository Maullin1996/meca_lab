import 'dart:async';

import 'package:atomic_design/atoms/app_tokens.dart';
import 'package:atomic_design/config/atomic_design_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/core/router/app_router.dart';
import 'package:meca_lab/features/dashboard/presentation/pages/dashboard_mobile_view.dart';
import 'package:meca_lab/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:meca_lab/features/dashboard/presentation/pages/dashboard_web_view.dart';
import 'package:meca_lab/features/dashboard/presentation/widgets/device_card.dart';
import 'package:meca_lab/features/device_detail/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/features/device_detail/domain/repositories/sensor_history_repository.dart';
import 'package:meca_lab/features/device_detail/presentation/pages/device_detail_page.dart';
import 'package:meca_lab/shared/data/repositories/device_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockDeviceRepository repository;
  late MockSensorHistoryRepository historyRepository;

  const mobileSize = Size(390, 844);
  const webSize = Size(1280, 800);

  Device buildDevice({
    required String id,
    required String name,
    required DeviceStatus status,
  }) => Device(
    id: id,
    siteId: 'site-1',
    name: name,
    type: DeviceType.compresor,
    status: status,
    lastConnection: DateTime(2026, 7, 31, 10),
    sensorCount: 1,
    keySensors: [
      Sensor(
        id: 'sensor-$id',
        deviceId: id,
        name: 'Temperatura',
        type: SensorType.temperatura,
        unit: '°C',
        currentValue: 50,
        safeMin: 0,
        safeMax: 100,
      ),
    ],
  );

  setUp(() async {
    repository = MockDeviceRepository();
    historyRepository = MockSensorHistoryRepository();
    when(
      () => historyRepository.watchSensorHistory(any()),
    ).thenAnswer((_) => const Stream.empty());
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  /// A real (if minimal) `GoRouter` — `DashboardPage.handleDeviceTap` uses
  /// `context.push`, which needs an ancestor `GoRouter` to resolve, not a
  /// plain `Navigator`.
  Widget buildApp() {
    final router = GoRouter(
      initialLocation: AppRoutes.dashboard,
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          builder: (context, state) => const DashboardPage(),
        ),
        GoRoute(
          path: AppRoutes.deviceDetail,
          builder: (context, state) =>
              DeviceDetailPage(deviceId: state.pathParameters['id']!),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        deviceRepositoryImplProvider.overrideWithValue(repository),
        sensorHistoryRepositoryImplProvider.overrideWithValue(
          historyRepository,
        ),
      ],
      child: AppThemeProvider(
        child: MaterialApp.router(routerConfig: router),
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

  testWidgets('ancho angosto renderiza DashboardMobileView', (tester) async {
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => const Stream.empty());

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(DashboardMobileView), findsOneWidget);
    expect(find.byType(DashboardWebView), findsNothing);
  });

  testWidgets('ancho ancho renderiza DashboardWebView', (tester) async {
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => const Stream.empty());

    await setSurfaceSize(tester, webSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(DashboardWebView), findsOneWidget);
    expect(find.byType(DashboardMobileView), findsNothing);
  });

  testWidgets('estado inicial (loading) no muestra cards de dispositivo', (
    tester,
  ) async {
    final controller = StreamController<Either<Failure, List<Device>>>();
    addTearDown(controller.close);
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => controller.stream);

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(DeviceCard), findsNothing);
  });

  testWidgets('con datos muestra una card por dispositivo', (tester) async {
    final devices = [
      buildDevice(id: 'dev-1', name: 'Compresor Norte', status: DeviceStatus.online),
      buildDevice(id: 'dev-2', name: 'Motor Backup', status: DeviceStatus.offline),
    ];
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => Stream.value(Right(devices)));

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(DeviceCard), findsNWidgets(2));
    expect(find.text('Compresor Norte'), findsOneWidget);
    expect(find.text('Motor Backup'), findsOneWidget);
  });

  testWidgets('el filtro de búsqueda solo muestra dispositivos que coinciden', (
    tester,
  ) async {
    final devices = [
      buildDevice(id: 'dev-1', name: 'Compresor Norte', status: DeviceStatus.online),
      buildDevice(id: 'dev-2', name: 'Motor Backup', status: DeviceStatus.offline),
    ];
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => Stream.value(Right(devices)));

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'Motor');
    await tester.pumpAndSettle();

    expect(find.byType(DeviceCard), findsNWidgets(1));
    expect(find.text('Motor Backup'), findsOneWidget);
    expect(find.text('Compresor Norte'), findsNothing);
  });

  testWidgets('estado de error si el repositorio falla', (tester) async {
    when(() => repository.watchDevices()).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('boom'))),
    );

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('No pudimos cargar los dispositivos'), findsOneWidget);
    expect(find.byType(DeviceCard), findsNothing);
  });

  testWidgets('tocar una card navega al detalle real del dispositivo', (
    tester,
  ) async {
    final devices = [
      buildDevice(id: 'dev-1', name: 'Compresor Norte', status: DeviceStatus.online),
    ];
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => Stream.value(Right(devices)));
    when(
      () => repository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => Stream.value(Right(devices.first)));
    when(
      () => repository.getSensorsForDevice('dev-1'),
    ).thenAnswer((_) async => const Right([]));

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DeviceCard));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardPage), findsNothing);
    expect(find.byType(DeviceDetailPage), findsOneWidget);
    expect(find.text('Compresor Norte'), findsOneWidget);
  });
}
