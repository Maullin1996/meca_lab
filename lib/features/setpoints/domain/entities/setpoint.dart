class Setpoint {
  final String id;
  final String deviceId;
  final String sensorId;
  final double min;
  final double max;
  final String unit;

  /// Name/email of whoever made the last change — not a reference to
  /// `User`, same denormalization criterion as `Alert.deviceName`.
  final String updatedBy;
  final DateTime updatedAt;

  const Setpoint({
    required this.id,
    required this.deviceId,
    required this.sensorId,
    required this.min,
    required this.max,
    required this.unit,
    required this.updatedBy,
    required this.updatedAt,
  });
}
