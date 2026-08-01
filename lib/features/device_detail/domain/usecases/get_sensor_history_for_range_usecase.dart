import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/sensor_history_range.dart';
import '../../../../shared/domain/entities/sensor_reading.dart';
import '../../../../shared/domain/repositories/sensor_history_repository.dart';

/// Exclusive to `device_detail` — its full chart is the only place that
/// needs a day/week/month read instead of the live buffer, so this doesn't
/// belong in `shared/domain/usecases/` alongside [SensorHistoryRepository]
/// itself (that repository gained the method; the caller didn't need to
/// become shared too).
class GetSensorHistoryForRangeUseCase {
  final SensorHistoryRepository repository;

  const GetSensorHistoryForRangeUseCase(this.repository);

  Future<Either<Failure, List<SensorReading>>> call(
    String sensorId,
    SensorHistoryRange range,
  ) {
    return repository.getHistoryForRange(sensorId, range);
  }
}
