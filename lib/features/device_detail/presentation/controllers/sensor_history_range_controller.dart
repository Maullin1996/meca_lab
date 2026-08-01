import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/data/repositories/sensor_history_repository_impl.dart';
import '../../../../shared/domain/entities/sensor_history_range.dart';
import '../../../../shared/domain/entities/sensor_reading.dart';
import '../../domain/usecases/get_sensor_history_for_range_usecase.dart';

part 'sensor_history_range_controller.g.dart';

/// One-shot read per `(sensorId, range)` — riverpod_generator infers the
/// family from the extra `build()` parameters, same as the other family
/// providers in this feature. A plain function provider (not a
/// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
/// `Future`, not a live stream — switching the range picker just reads a
/// different cached value instead of resubscribing to anything.
@riverpod
Future<List<SensorReading>> sensorHistoryForRange(
  Ref ref,
  String sensorId,
  SensorHistoryRange range,
) async {
  final repository = ref.watch(sensorHistoryRepositoryImplProvider);
  final useCase = GetSensorHistoryForRangeUseCase(repository);
  final result = await useCase(sensorId, range);

  return result.fold((failure) => throw failure, (readings) => readings);
}
