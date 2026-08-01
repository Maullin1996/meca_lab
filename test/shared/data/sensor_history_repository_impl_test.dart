import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/sensor_reading.dart';
import 'package:mocktail/mocktail.dart';

class MockMockDeviceDataSource extends Mock implements MockDeviceDataSource {}

void main() {
  late MockMockDeviceDataSource dataSource;
  late SensorHistoryRepositoryImpl repository;

  final history = [
    SensorHistoryPoint(timestamp: DateTime(2026, 7, 31, 10), value: 62),
    SensorHistoryPoint(timestamp: DateTime(2026, 7, 31, 10, 0, 4), value: 63),
  ];

  setUp(() {
    dataSource = MockMockDeviceDataSource();
    repository = SensorHistoryRepositoryImpl(dataSource);
  });

  test('envuelve el historial del data source en Right como SensorReading', () async {
    when(
      () => dataSource.historyStream('sensor-1'),
    ).thenAnswer((_) => Stream.value(history));

    await expectLater(
      repository.watchSensorHistory('sensor-1'),
      emits(
        isA<Right<Failure, List<SensorReading>>>().having(
          (right) => right.value,
          'value',
          [
            isA<SensorReading>()
                .having((r) => r.sensorId, 'sensorId', 'sensor-1')
                .having((r) => r.timestamp, 'timestamp', history[0].timestamp)
                .having((r) => r.value, 'value', history[0].value),
            isA<SensorReading>()
                .having((r) => r.sensorId, 'sensorId', 'sensor-1')
                .having((r) => r.timestamp, 'timestamp', history[1].timestamp)
                .having((r) => r.value, 'value', history[1].value),
          ],
        ),
      ),
    );
  });

  test('envuelve un error del stream en Left(UnexpectedFailure)', () async {
    when(
      () => dataSource.historyStream('sensor-1'),
    ).thenAnswer((_) => Stream<List<SensorHistoryPoint>>.error(Exception('boom')));

    await expectLater(
      repository.watchSensorHistory('sensor-1'),
      emits(isA<Left<Failure, List<SensorReading>>>()),
    );
  });
}
