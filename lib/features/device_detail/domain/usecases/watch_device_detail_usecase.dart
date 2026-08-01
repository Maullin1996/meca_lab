import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/repositories/device_repository.dart';
import '../entities/device_detail.dart';

/// Combines [DeviceRepository.watchDeviceById] with
/// [DeviceRepository.getSensorsForDevice] so presentation gets a single
/// stream of the device and its full sensor list, instead of juggling a
/// stream and a future itself.
class WatchDeviceDetailUseCase {
  final DeviceRepository repository;

  const WatchDeviceDetailUseCase(this.repository);

  Stream<Either<Failure, DeviceDetail>> call(String deviceId) {
    return repository
        .watchDeviceById(deviceId)
        .asyncMap(
          (deviceResult) => deviceResult.match(
            (failure) => Future.value(Left<Failure, DeviceDetail>(failure)),
            (device) async {
              final sensorsResult = await repository.getSensorsForDevice(
                deviceId,
              );
              return sensorsResult.match(
                (failure) => Left<Failure, DeviceDetail>(failure),
                (sensors) => Right<Failure, DeviceDetail>(
                  DeviceDetail(device: device, sensors: sensors),
                ),
              );
            },
          ),
        );
  }
}
