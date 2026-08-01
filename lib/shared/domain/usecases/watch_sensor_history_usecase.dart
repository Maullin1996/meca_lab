import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../entities/sensor_reading.dart';
import '../repositories/sensor_history_repository.dart';

class WatchSensorHistoryUseCase {
  final SensorHistoryRepository repository;

  const WatchSensorHistoryUseCase(this.repository);

  Stream<Either<Failure, List<SensorReading>>> call(String sensorId) {
    return repository.watchSensorHistory(sensorId);
  }
}
