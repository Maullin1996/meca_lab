import '../../domain/entities/sensor.dart';

class SensorModel {
  final String id;
  final String deviceId;
  final String name;
  final SensorType type;
  final String unit;
  final double currentValue;
  final double safeMin;
  final double safeMax;

  const SensorModel({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.unit,
    required this.currentValue,
    required this.safeMin,
    required this.safeMax,
  });

  factory SensorModel.fromEntity(Sensor sensor) => SensorModel(
    id: sensor.id,
    deviceId: sensor.deviceId,
    name: sensor.name,
    type: sensor.type,
    unit: sensor.unit,
    currentValue: sensor.currentValue,
    safeMin: sensor.safeMin,
    safeMax: sensor.safeMax,
  );

  Sensor toEntity() => Sensor(
    id: id,
    deviceId: deviceId,
    name: name,
    type: type,
    unit: unit,
    currentValue: currentValue,
    safeMin: safeMin,
    safeMax: safeMax,
  );

  factory SensorModel.fromJson(Map<String, dynamic> json) => SensorModel(
    id: json['id'] as String,
    deviceId: json['device_id'] as String,
    name: json['name'] as String,
    type: SensorType.values.byName(json['type'] as String),
    unit: json['unit'] as String,
    currentValue: (json['current_value'] as num).toDouble(),
    safeMin: (json['safe_min'] as num).toDouble(),
    safeMax: (json['safe_max'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_id': deviceId,
    'name': name,
    'type': type.name,
    'unit': unit,
    'current_value': currentValue,
    'safe_min': safeMin,
    'safe_max': safeMax,
  };
}
