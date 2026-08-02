import '../../domain/entities/alert.dart';

class AlertModel {
  final String id;
  final String deviceId;
  final String deviceName;
  final String? sensorId;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final AlertStatus status;

  const AlertModel({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    this.sensorId,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory AlertModel.fromEntity(Alert alert) => AlertModel(
    id: alert.id,
    deviceId: alert.deviceId,
    deviceName: alert.deviceName,
    sensorId: alert.sensorId,
    severity: alert.severity,
    message: alert.message,
    timestamp: alert.timestamp,
    status: alert.status,
  );

  Alert toEntity() => Alert(
    id: id,
    deviceId: deviceId,
    deviceName: deviceName,
    sensorId: sensorId,
    severity: severity,
    message: message,
    timestamp: timestamp,
    status: status,
  );

  factory AlertModel.fromJson(Map<String, dynamic> json) => AlertModel(
    id: json['id'] as String,
    deviceId: json['device_id'] as String,
    deviceName: json['device_name'] as String,
    sensorId: json['sensor_id'] as String?,
    severity: AlertSeverity.values.byName(json['severity'] as String),
    message: json['message'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    status: AlertStatus.values.byName(json['status'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'device_id': deviceId,
    'device_name': deviceName,
    'sensor_id': sensorId,
    'severity': severity.name,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'status': status.name,
  };
}
