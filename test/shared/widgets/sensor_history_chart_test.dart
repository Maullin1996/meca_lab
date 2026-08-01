import 'package:atomic_design/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/shared/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/sensor_reading.dart';
import 'package:meca_lab/shared/domain/repositories/sensor_history_repository.dart';
import 'package:meca_lab/shared/widgets/sensor_history_chart.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository repository;

  final readings = [
    SensorReading(
      sensorId: 'sensor-1',
      timestamp: DateTime(2026, 7, 31, 10),
      value: 62,
    ),
    SensorReading(
      sensorId: 'sensor-1',
      timestamp: DateTime(2026, 7, 31, 10, 0, 4),
      value: 63,
    ),
  ];

  setUp(() async {
    repository = MockSensorHistoryRepository();
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp(Widget child) {
    return ProviderScope(
      overrides: [
        sensorHistoryRepositoryImplProvider.overrideWithValue(repository),
      ],
      child: AppThemeProvider(child: MaterialApp(home: Scaffold(body: child))),
    );
  }

  testWidgets('con menos de dos lecturas no dibuja la línea', (tester) async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(Right([readings.first])),
    );

    await tester.pumpWidget(
      buildApp(const SensorHistoryChart(sensorId: 'sensor-1')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('con dos o más lecturas dibuja la línea', (tester) async {
    when(
      () => repository.watchSensorHistory('sensor-1'),
    ).thenAnswer((_) => Stream.value(Right(readings)));

    await tester.pumpWidget(
      buildApp(const SensorHistoryChart(sensorId: 'sensor-1')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('un error en el historial no dibuja la línea', (tester) async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('boom'))),
    );

    await tester.pumpWidget(
      buildApp(const SensorHistoryChart(sensorId: 'sensor-1')),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('el modo compacto oculta grid y borde', (tester) async {
    when(
      () => repository.watchSensorHistory('sensor-1'),
    ).thenAnswer((_) => Stream.value(Right(readings)));

    await tester.pumpWidget(
      buildApp(
        const SensorHistoryChart(
          sensorId: 'sensor-1',
          variant: ChartVariant.compact,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.gridData.show, isFalse);
    expect(chart.data.borderData.show, isFalse);
    expect(chart.data.titlesData.show, isFalse);
  });

  testWidgets('el modo full muestra grid y borde', (tester) async {
    when(
      () => repository.watchSensorHistory('sensor-1'),
    ).thenAnswer((_) => Stream.value(Right(readings)));

    await tester.pumpWidget(
      buildApp(const SensorHistoryChart(sensorId: 'sensor-1')),
    );
    await tester.pumpAndSettle();

    final chart = tester.widget<LineChart>(find.byType(LineChart));
    expect(chart.data.gridData.show, isTrue);
    expect(chart.data.borderData.show, isTrue);
  });

  testWidgets('isLive en false usa un color apagado y sin animación', (
    tester,
  ) async {
    when(
      () => repository.watchSensorHistory('sensor-1'),
    ).thenAnswer((_) => Stream.value(Right(readings)));

    await tester.pumpWidget(
      buildApp(
        const SensorHistoryChart(sensorId: 'sensor-1', isLive: false),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(LineChart));
    final colors = AppColors.of(context);
    final chart = tester.widget<LineChart>(find.byType(LineChart));

    expect(chart.data.lineBarsData.first.color, colors.textDisabled);
    expect(chart.duration, Duration.zero);
  });
}
