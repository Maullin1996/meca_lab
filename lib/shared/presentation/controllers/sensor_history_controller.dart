import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/sensor_history_repository_impl.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/usecases/watch_sensor_history_usecase.dart';

part 'sensor_history_controller.g.dart';

/// Same reasoning as `DeviceDetailController` — the mock stream doesn't
/// recover on error, so the default unlimited-retry policy would just spin.
Duration? _neverRetry(int retryCount, Object error) => null;

/// One controller instance per `sensorId`, deliberately separate from
/// [DeviceDetailController]: each sensor card on the device_detail screen
/// watches its own history independently, instead of one giant state
/// covering every sensor on the device.
@Riverpod(retry: _neverRetry)
class SensorHistoryController extends _$SensorHistoryController {
  @override
  Stream<List<SensorReading>> build(String sensorId) async* {
    final repository = ref.watch(sensorHistoryRepositoryImplProvider);
    final watchSensorHistory = WatchSensorHistoryUseCase(repository);

    await for (final result in watchSensorHistory(sensorId)) {
      yield result.fold((failure) => throw failure, (readings) => readings);
    }
  }
}
