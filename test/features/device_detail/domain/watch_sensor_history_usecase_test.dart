import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/domain/entities/sensor_reading.dart';
import 'package:meca_lab/features/device_detail/domain/repositories/sensor_history_repository.dart';
import 'package:meca_lab/features/device_detail/domain/usecases/watch_sensor_history_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository repository;
  late WatchSensorHistoryUseCase useCase;

  setUp(() {
    repository = MockSensorHistoryRepository();
    useCase = WatchSensorHistoryUseCase(repository);
  });

  final readings = [
    SensorReading(
      sensorId: 'sensor-1',
      timestamp: DateTime(2026, 7, 31, 10),
      value: 65,
    ),
  ];

  test('emite Right con el historial de lecturas', () async {
    when(
      () => repository.watchSensorHistory('sensor-1'),
    ).thenAnswer((_) => Stream.value(Right(readings)));

    await expectLater(
      useCase('sensor-1'),
      emits(Right<Failure, List<SensorReading>>(readings)),
    );
  });

  test('emite Left cuando el historial no está disponible', () async {
    when(() => repository.watchSensorHistory('sensor-1')).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('history unavailable'))),
    );

    await expectLater(
      useCase('sensor-1'),
      emits(const Left<Failure, List<SensorReading>>(UnexpectedFailure('history unavailable'))),
    );
  });
}
