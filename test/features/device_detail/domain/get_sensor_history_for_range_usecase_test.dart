import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/domain/usecases/get_sensor_history_for_range_usecase.dart';
import 'package:meca_lab/shared/domain/entities/sensor_history_range.dart';
import 'package:meca_lab/shared/domain/entities/sensor_reading.dart';
import 'package:meca_lab/shared/domain/repositories/sensor_history_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository repository;
  late GetSensorHistoryForRangeUseCase useCase;

  setUp(() {
    repository = MockSensorHistoryRepository();
    useCase = GetSensorHistoryForRangeUseCase(repository);
  });

  final readings = [
    SensorReading(
      sensorId: 'sensor-1',
      timestamp: DateTime(2026, 7, 31, 10),
      value: 65,
    ),
  ];

  test('devuelve Right con el historial del rango pedido', () async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.month),
    ).thenAnswer((_) async => Right(readings));

    final result = await useCase('sensor-1', SensorHistoryRange.month);

    expect(result, Right<Failure, List<SensorReading>>(readings));
  });

  test('devuelve Left cuando el repositorio falla', () async {
    when(
      () => repository.getHistoryForRange('sensor-1', SensorHistoryRange.day),
    ).thenAnswer(
      (_) async => const Left(UnexpectedFailure('history unavailable')),
    );

    final result = await useCase('sensor-1', SensorHistoryRange.day);

    expect(
      result,
      const Left<Failure, List<SensorReading>>(
        UnexpectedFailure('history unavailable'),
      ),
    );
  });
}
