import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failures.dart';
import '../datasources/mock_device_data_source.dart';
import '../../domain/entities/sensor_history_range.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/repositories/sensor_history_repository.dart';

part 'sensor_history_repository_impl.g.dart';

class SensorHistoryRepositoryImpl implements SensorHistoryRepository {
  final MockDeviceDataSource dataSource;

  const SensorHistoryRepositoryImpl(this.dataSource);

  @override
  Stream<Either<Failure, List<SensorReading>>> watchSensorHistory(
    String sensorId,
  ) async* {
    try {
      await for (final history in dataSource.historyStream(sensorId)) {
        yield Right([
          for (final point in history)
            SensorReading(
              sensorId: sensorId,
              timestamp: point.timestamp,
              value: point.value,
            ),
        ]);
      }
    } catch (e) {
      yield Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SensorReading>>> getHistoryForRange(
    String sensorId,
    SensorHistoryRange range,
  ) async {
    try {
      final points = dataSource.generateHistoryForRange(sensorId, range);
      return Right([
        for (final point in points)
          SensorReading(
            sensorId: sensorId,
            timestamp: point.timestamp,
            value: point.value,
          ),
      ]);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
SensorHistoryRepository sensorHistoryRepositoryImpl(Ref ref) {
  final dataSource = ref.watch(mockDeviceDataSourceProvider);
  return SensorHistoryRepositoryImpl(dataSource);
}
