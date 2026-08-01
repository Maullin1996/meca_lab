enum SensorType { temperatura, presion, vibracion, corriente, rpm }

class Sensor {
  final String id;
  final String deviceId;
  final String name;
  final SensorType type;
  final String unit;
  final double currentValue;
  final double safeMin;
  final double safeMax;

  const Sensor({
    required this.id,
    required this.deviceId,
    required this.name,
    required this.type,
    required this.unit,
    required this.currentValue,
    required this.safeMin,
    required this.safeMax,
  });
}
