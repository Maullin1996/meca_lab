import 'sensor.dart';

enum DeviceType { compresor, motor, bomba, banda }

enum DeviceStatus { online, warning, critical, offline }

class Device {
  final String id;
  final String siteId;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime lastConnection;

  /// Total number of sensors this device has. The dashboard needs this for
  /// its "active sensors" KPI without needing the full sensor list.
  final int sensorCount;

  /// A 1-2 sensor snapshot for the dashboard card. Not the full sensor
  /// list — device_detail will decide separately how it reads all of a
  /// device's sensors when that feature exists.
  final List<Sensor> keySensors;

  const Device({
    required this.id,
    required this.siteId,
    required this.name,
    required this.type,
    required this.status,
    required this.lastConnection,
    required this.sensorCount,
    required this.keySensors,
  });
}
