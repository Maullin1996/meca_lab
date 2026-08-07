enum AlertSeverity { info, warning, critical }

enum AlertStatus { active, acknowledged, resolved }

class Alert {
  final String id;
  final String deviceId;

  /// Denormalized at mock-generation time — this feature has no dependency
  /// on `DeviceRepository`.
  final String deviceName;
  final String? sensorId;
  final AlertSeverity severity;
  final String message;
  final DateTime timestamp;
  final AlertStatus status;

  const Alert({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    this.sensorId,
    required this.severity,
    required this.message,
    required this.timestamp,
    required this.status,
  });
}
