import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/shared/data/models/alert_model.dart';
import 'package:meca_lab/shared/domain/entities/alert.dart';

void main() {
  final model = AlertModel(
    id: 'alert-1',
    deviceId: 'device-1',
    deviceName: 'Compresor Norte',
    sensorId: 'sensor-1',
    severity: AlertSeverity.warning,
    message: 'Temperatura por encima del rango seguro',
    timestamp: DateTime(2026, 8, 1, 10, 30),
    status: AlertStatus.active,
  );

  test('fromJson(toJson()) reconstruye el mismo AlertModel', () {
    final roundTripped = AlertModel.fromJson(model.toJson());

    expect(roundTripped.id, model.id);
    expect(roundTripped.deviceId, model.deviceId);
    expect(roundTripped.deviceName, model.deviceName);
    expect(roundTripped.sensorId, model.sensorId);
    expect(roundTripped.severity, model.severity);
    expect(roundTripped.message, model.message);
    expect(roundTripped.timestamp, model.timestamp);
    expect(roundTripped.status, model.status);
  });

  test('fromJson(toJson()) preserva un sensorId nulo', () {
    final withoutSensor = AlertModel(
      id: 'alert-2',
      deviceId: 'device-1',
      deviceName: 'Compresor Norte',
      severity: AlertSeverity.info,
      message: 'Conexión inestable',
      timestamp: DateTime(2026, 8, 1, 9),
      status: AlertStatus.resolved,
    );

    final roundTripped = AlertModel.fromJson(withoutSensor.toJson());

    expect(roundTripped.sensorId, isNull);
  });

  test('toEntity()/fromEntity() mapean sin pérdida hacia y desde Alert', () {
    final entity = model.toEntity();
    final rebuiltModel = AlertModel.fromEntity(entity);

    expect(entity.id, model.id);
    expect(entity.sensorId, model.sensorId);
    expect(rebuiltModel.toJson(), model.toJson());
  });
}
