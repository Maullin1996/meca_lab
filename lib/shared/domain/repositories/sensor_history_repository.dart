import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../entities/sensor_history_range.dart';
import '../entities/sensor_reading.dart';

abstract class SensorHistoryRepository {
  /// Emits a sensor's reading history on every simulated update.
  Stream<Either<Failure, List<SensorReading>>> watchSensorHistory(
    String sensorId,
  );

  /// One-shot historical read for a coarser [range] (day/week/month),
  /// independent of [watchSensorHistory]'s live buffer.
  Future<Either<Failure, List<SensorReading>>> getHistoryForRange(
    String sensorId,
    SensorHistoryRange range,
  );
}
