import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/data/datasources/mock_device_data_source.dart';
import '../../../../shared/domain/entities/device.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

part 'mock_alert_repository_impl.g.dart';

/// Seeds its factory alerts from [MockDeviceDataSource]'s device list so an
/// alert on "Compresor Norte" references a device that really exists (and
/// really is in that status) elsewhere in the demo. This is `data`-to-`data`
/// coupling (one mock source reading another), not `domain`-to-`domain` —
/// `Alert` still denormalizes `deviceId`/`deviceName` with no dependency on
/// `DeviceRepository`.
class MockAlertRepositoryImpl implements AlertRepository {
  MockAlertRepositoryImpl(this.dataSource) {
    _alerts = _seedAlerts(dataSource.currentDevices);
  }

  final MockDeviceDataSource dataSource;
  late final List<Alert> _alerts;

  @override
  Future<Either<Failure, List<Alert>>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return Right(List.unmodifiable(_alerts));
  }

  /// Acknowledging an alert that is already `acknowledged` or `resolved` is
  /// an idempotent no-op — it returns the alert unchanged instead of a
  /// failure. Only an `active` alert actually transitions.
  @override
  Future<Either<Failure, Alert>> acknowledgeAlert(String alertId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _alerts.indexWhere((alert) => alert.id == alertId);
    if (index == -1) {
      return Left(NotFoundFailure('alert not found: $alertId'));
    }

    final current = _alerts[index];
    if (current.status != AlertStatus.active) {
      return Right(current);
    }

    final updated = Alert(
      id: current.id,
      deviceId: current.deviceId,
      deviceName: current.deviceName,
      sensorId: current.sensorId,
      severity: current.severity,
      message: current.message,
      timestamp: current.timestamp,
      status: AlertStatus.acknowledged,
    );
    _alerts[index] = updated;
    return Right(updated);
  }

  static List<Alert> _seedAlerts(List<Device> devices) {
    Device byId(String id) => devices.firstWhere((device) => device.id == id);

    final bombaSur = byId('device-bomba-sur');
    final bandaTransportadora = byId('device-banda-transportadora-2');
    final compresorNorte = byId('device-compresor-norte');
    final motorLinea3 = byId('device-motor-linea-3');
    final motorBackup = byId('device-motor-backup');

    final now = DateTime.now();

    Alert alert({
      required String id,
      required Device device,
      String? sensorId,
      required AlertSeverity severity,
      required String message,
      required AlertStatus status,
      required Duration age,
    }) => Alert(
      id: id,
      deviceId: device.id,
      deviceName: device.name,
      sensorId: sensorId,
      severity: severity,
      message: message,
      timestamp: now.subtract(age),
      status: status,
    );

    return [
      // `critical` device: prioritize warning/critical, active alerts.
      alert(
        id: 'alert-bomba-sur-presion',
        device: bombaSur,
        sensorId: 'sensor-bomba-sur-presion',
        severity: AlertSeverity.critical,
        message: 'Presión fuera de rango seguro',
        status: AlertStatus.active,
        age: const Duration(minutes: 5),
      ),
      alert(
        id: 'alert-bomba-sur-conexion',
        device: bombaSur,
        severity: AlertSeverity.warning,
        message: 'Conexión inestable con el gateway',
        status: AlertStatus.active,
        age: const Duration(minutes: 12),
      ),
      alert(
        id: 'alert-bomba-sur-temp',
        device: bombaSur,
        sensorId: 'sensor-bomba-sur-temp',
        severity: AlertSeverity.warning,
        message: 'Temperatura elevada, monitorear',
        status: AlertStatus.active,
        age: const Duration(minutes: 20),
      ),
      // `warning` device: prioritize warning alerts too.
      alert(
        id: 'alert-banda-vibracion',
        device: bandaTransportadora,
        sensorId: 'sensor-banda-transportadora-2-vibracion',
        severity: AlertSeverity.warning,
        message: 'Vibración cerca del límite superior',
        status: AlertStatus.active,
        age: const Duration(hours: 1),
      ),
      alert(
        id: 'alert-banda-corriente',
        device: bandaTransportadora,
        sensorId: 'sensor-banda-transportadora-2-corriente',
        severity: AlertSeverity.info,
        message: 'Corriente normalizada tras pico',
        status: AlertStatus.resolved,
        age: const Duration(hours: 3),
      ),
      // `online` devices: at most one resolved alert, never active.
      alert(
        id: 'alert-compresor-mantenimiento',
        device: compresorNorte,
        severity: AlertSeverity.info,
        message: 'Mantenimiento programado registrado',
        status: AlertStatus.acknowledged,
        age: const Duration(days: 1),
      ),
      alert(
        id: 'alert-motor-linea-3-rpm',
        device: motorLinea3,
        sensorId: 'sensor-motor-linea-3-rpm',
        severity: AlertSeverity.info,
        message: 'Pico de RPM transitorio, ya normalizado',
        status: AlertStatus.resolved,
        age: const Duration(days: 2),
      ),
      alert(
        id: 'alert-motor-backup-conexion',
        device: motorBackup,
        severity: AlertSeverity.critical,
        message: 'Dispositivo sin comunicación',
        status: AlertStatus.active,
        age: const Duration(hours: 6),
      ),
    ];
  }
}

@Riverpod(keepAlive: true)
AlertRepository alertRepositoryImpl(Ref ref) {
  final dataSource = ref.watch(mockDeviceDataSourceProvider);
  return MockAlertRepositoryImpl(dataSource);
}
