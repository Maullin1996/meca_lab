import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/features/device_detail/domain/entities/sensor_reading.dart';
import 'package:meca_lab/features/device_detail/domain/repositories/sensor_history_repository.dart';
import 'package:meca_lab/features/device_detail/presentation/widgets/sensor_sparkline.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository repository;

  // `Scaffold`/`MaterialApp` already paint their own `CustomPaint`s, so
  // `findSparklinePaint` alone over-matches — narrow to the sparkline's
  // own private painter by its runtime type name.
  final findSparklinePaint = find.byWidgetPredicate(
    (widget) =>
        widget is CustomPaint &&
        widget.painter.runtimeType.toString() == '_SparklinePainter',
  );

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
      child: const AppThemeProvider(
        child: MaterialApp(
          home: Scaffold(body: SensorSparkline(sensorId: 'sensor-1')),
        ),
      ),
    );
  }

  testWidgets('con menos de dos lecturas no dibuja la línea', (tester) async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(
        Right([
          SensorReading(
            sensorId: 'sensor-1',
            timestamp: DateTime(2026, 7, 31, 10),
            value: 62,
          ),
        ]),
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(findSparklinePaint, findsNothing);
  });

  testWidgets('con dos o más lecturas dibuja la línea', (tester) async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(
        Right([
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
        ]),
      ),
    );

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(findSparklinePaint, findsOneWidget);
  });

  testWidgets('un error en el historial no dibuja la línea', (tester) async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('boom'))),
    );

    await tester.pumpWidget(buildApp());
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(findSparklinePaint, findsNothing);
  });
}
