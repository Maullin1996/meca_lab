import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/features/setpoints/data/models/setpoint_model.dart';

void main() {
  final model = SetpointModel(
    id: 'setpoint-sensor-1',
    deviceId: 'device-1',
    sensorId: 'sensor-1',
    min: 20,
    max: 90,
    unit: '°C',
    updatedBy: 'Andrés Torres',
    updatedAt: DateTime(2026, 8, 1, 10, 30),
  );

  test('fromJson(toJson()) reconstruye el mismo SetpointModel', () {
    final roundTripped = SetpointModel.fromJson(model.toJson());

    expect(roundTripped.id, model.id);
    expect(roundTripped.deviceId, model.deviceId);
    expect(roundTripped.sensorId, model.sensorId);
    expect(roundTripped.min, model.min);
    expect(roundTripped.max, model.max);
    expect(roundTripped.unit, model.unit);
    expect(roundTripped.updatedBy, model.updatedBy);
    expect(roundTripped.updatedAt, model.updatedAt);
  });

  test('toEntity()/fromEntity() mapean sin pérdida hacia y desde Setpoint', () {
    final entity = model.toEntity();
    final rebuiltModel = SetpointModel.fromEntity(entity);

    expect(entity.id, model.id);
    expect(entity.min, model.min);
    expect(entity.max, model.max);
    expect(rebuiltModel.toJson(), model.toJson());
  });
}
