import '../../domain/entities/sensor_reading.dart';

class SensorReadingModel {
  final String sensorId;
  final DateTime timestamp;
  final double value;

  const SensorReadingModel({
    required this.sensorId,
    required this.timestamp,
    required this.value,
  });

  factory SensorReadingModel.fromEntity(SensorReading reading) =>
      SensorReadingModel(
        sensorId: reading.sensorId,
        timestamp: reading.timestamp,
        value: reading.value,
      );

  SensorReading toEntity() => SensorReading(
    sensorId: sensorId,
    timestamp: timestamp,
    value: value,
  );

  factory SensorReadingModel.fromJson(Map<String, dynamic> json) =>
      SensorReadingModel(
        sensorId: json['sensor_id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        value: (json['value'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
    'sensor_id': sensorId,
    'timestamp': timestamp.toIso8601String(),
    'value': value,
  };
}
