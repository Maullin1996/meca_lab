import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../entities/device.dart';
import '../entities/sensor.dart';

abstract class DeviceRepository {
  /// Emits the current device list on every simulated update.
  Stream<Either<Failure, List<Device>>> watchDevices();

  /// Emits a single device's current state on every simulated update.
  Stream<Either<Failure, Device>> watchDeviceById(String id);

  /// Returns a device's full sensor list (not the dashboard's [Device.keySensors] snapshot).
  Future<Either<Failure, List<Sensor>>> getSensorsForDevice(String deviceId);
}
