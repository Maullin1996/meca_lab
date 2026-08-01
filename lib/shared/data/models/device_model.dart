import '../../domain/entities/device.dart';
import 'sensor_model.dart';

class DeviceModel {
  final String id;
  final String siteId;
  final String name;
  final DeviceType type;
  final DeviceStatus status;
  final DateTime lastConnection;
  final int sensorCount;
  final List<SensorModel> keySensors;

  const DeviceModel({
    required this.id,
    required this.siteId,
    required this.name,
    required this.type,
    required this.status,
    required this.lastConnection,
    required this.sensorCount,
    required this.keySensors,
  });

  factory DeviceModel.fromEntity(Device device) => DeviceModel(
    id: device.id,
    siteId: device.siteId,
    name: device.name,
    type: device.type,
    status: device.status,
    lastConnection: device.lastConnection,
    sensorCount: device.sensorCount,
    keySensors: device.keySensors.map(SensorModel.fromEntity).toList(),
  );

  Device toEntity() => Device(
    id: id,
    siteId: siteId,
    name: name,
    type: type,
    status: status,
    lastConnection: lastConnection,
    sensorCount: sensorCount,
    keySensors: keySensors.map((sensor) => sensor.toEntity()).toList(),
  );

  factory DeviceModel.fromJson(Map<String, dynamic> json) => DeviceModel(
    id: json['id'] as String,
    siteId: json['site_id'] as String,
    name: json['name'] as String,
    type: DeviceType.values.byName(json['type'] as String),
    status: DeviceStatus.values.byName(json['status'] as String),
    lastConnection: DateTime.parse(json['last_connection'] as String),
    sensorCount: json['sensor_count'] as int,
    keySensors: (json['key_sensors'] as List<dynamic>)
        .map((raw) => SensorModel.fromJson(raw as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'site_id': siteId,
    'name': name,
    'type': type.name,
    'status': status.name,
    'last_connection': lastConnection.toIso8601String(),
    'sensor_count': sensorCount,
    'key_sensors': keySensors.map((sensor) => sensor.toJson()).toList(),
  };
}
