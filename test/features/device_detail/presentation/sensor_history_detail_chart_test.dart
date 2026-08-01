import 'package:atomic_design/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/presentation/widgets/sensor_history_detail_chart.dart';
import 'package:meca_lab/shared/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/sensor_history_range.dart';
import 'package:meca_lab/shared/domain/entities/sensor_reading.dart';
import 'package:meca_lab/shared/domain/repositories/sensor_history_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository repository;

  List<SensorReading> readings(int count) => [
    for (var i = 0; i < count; i++)
      SensorReading(
        sensorId: 'sensor-1',
        timestamp: DateTime(2026, 7, 31).add(Duration(hours: i)),
        value: 60 + i.toDouble(),
      ),
  ];

  setUp(() async {
    repository = MockSensorHistoryRepository();
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        sensorHistoryRepositoryImplProvider.overrideWithValue(repository),
      ],
      child: AppThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SensorHistoryDetailChart(sensorId: 'sensor-1', unit: '°C'),
          ),
        ),
      ),
    );
  }

  testWidgets('por defecto pide el rango de un día y dibuja el chart', (
    tester,
  ) async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).thenAnswer((_) async => Right(readings(24)));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Historial — Día'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
    verify(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).called(1);
  });

  testWidgets('el menú permite cambiar a semana y vuelve a pedir ese rango', (
    tester,
  ) async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).thenAnswer((_) async => Right(readings(24)));
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.week),
    ).thenAnswer((_) async => Right(readings(7)));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(PopupMenuButton<SensorHistoryRange>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semana').last);
    await tester.pumpAndSettle();

    expect(find.text('Historial — Semana'), findsOneWidget);
    verify(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.week),
    ).called(1);
  });

  testWidgets('con menos de dos lecturas muestra el mensaje de datos insuficientes', (
    tester,
  ) async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).thenAnswer((_) async => Right(readings(1)));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Sin datos suficientes'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('un error en el repositorio muestra el mensaje de error', (
    tester,
  ) async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).thenAnswer(
      (_) async => const Left(UnexpectedFailure('boom')),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No se pudo cargar el historial'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });
}
