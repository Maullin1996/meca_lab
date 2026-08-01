import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../entities/sensor_reading.dart';

abstract class SensorHistoryRepository {
  /// Emits a sensor's reading history on every simulated update.
  Stream<Either<Failure, List<SensorReading>>> watchSensorHistory(
    String sensorId,
  );
}
