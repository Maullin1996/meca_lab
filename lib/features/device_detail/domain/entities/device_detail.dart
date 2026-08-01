import '../../../../shared/domain/entities/device.dart';
import '../../../../shared/domain/entities/sensor.dart';

/// Combines a [Device] with its full [Sensor] list for the device detail
/// screen. Exclusive to this feature — the dashboard only needs
/// [Device.keySensors], so this doesn't belong in `shared/domain`.
class DeviceDetail {
  final Device device;
  final List<Sensor> sensors;

  const DeviceDetail({required this.device, required this.sensors});
}
