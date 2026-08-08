import '../../domain/entities/setpoint.dart';

class SetpointModel {
  final String id;
  final String deviceId;
  final String sensorId;
  final double min;
  final double max;
  final String unit;
  final String updatedBy;
  final DateTime updatedAt;

  const SetpointModel({
    required this.id,
    required this.deviceId,
    required this.sensorId,
    required this.min,
    required this.max,
    required this.unit,
    required this.updatedBy,
    required this.updatedAt,
  });

  factory SetpointModel.fromEntity(Setpoint setpoint) => SetpointModel(
    id: setpoint.id,
    deviceId: setpoint.deviceId,
    sensorId: setpoint.sensorId,
    min: setpoint.min,
    max: setpoint.max,
    unit: setpoint.unit,
    updatedBy: setpoint.updatedBy,
    updatedAt: setpoint.updatedAt,
  );

  Setpoint toEntity() => Setpoint(
    id: id,
    deviceId: deviceId,
    sensorId: sensorId,
    min: min,
    max: max,
    unit: unit,
    updatedBy: updatedBy,
    updatedAt: updatedAt,
  );

  factory SetpointModel.fromJson(Map<String, dynamic> json) => SetpointModel(
    id: json['id'] as String,
    deviceId: json['device_id'] as String,
    sensorId: json['sensor_id'] as String,
    min: (json['min'] as num).toDouble(),
    max: (json['max'] as num).toDouble(),
    unit: json['unit'] as String,
    updatedBy: json['updated_by'] as String,
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_id': deviceId,
    'sensor_id': sensorId,
    'min': min,
    'max': max,
    'unit': unit,
    'updated_by': updatedBy,
    'updated_at': updatedAt.toIso8601String(),
  };
}
