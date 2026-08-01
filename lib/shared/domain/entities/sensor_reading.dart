class SensorReading {
  final String sensorId;
  final DateTime timestamp;
  final double value;

  const SensorReading({
    required this.sensorId,
    required this.timestamp,
    required this.value,
  });
}
