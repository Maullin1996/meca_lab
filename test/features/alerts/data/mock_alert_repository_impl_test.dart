import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/alerts/data/repositories/mock_alert_repository_impl.dart';
import 'package:meca_lab/features/alerts/domain/entities/alert.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:mocktail/mocktail.dart';

class MockMockDeviceDataSource extends Mock implements MockDeviceDataSource {}

void main() {
  late MockMockDeviceDataSource dataSource;
  late MockAlertRepositoryImpl repository;

  final devices = [
    Device(
      id: 'device-compresor-norte',
      siteId: 'site-1',
      name: 'Compresor Norte',
      type: DeviceType.compresor,
      status: DeviceStatus.online,
      lastConnection: DateTime(2026, 8, 1, 8),
      sensorCount: 2,
      keySensors: const [],
    ),
    Device(
      id: 'device-motor-linea-3',
      siteId: 'site-1',
      name: 'Motor Línea 3',
      type: DeviceType.motor,
      status: DeviceStatus.online,
      lastConnection: DateTime(2026, 8, 1, 8),
      sensorCount: 2,
      keySensors: const [],
    ),
    Device(
      id: 'device-banda-transportadora-2',
      siteId: 'site-1',
      name: 'Banda Transportadora 2',
      type: DeviceType.banda,
      status: DeviceStatus.warning,
      lastConnection: DateTime(2026, 8, 1, 8),
      sensorCount: 2,
      keySensors: const [],
    ),
    Device(
      id: 'device-bomba-sur',
      siteId: 'site-1',
      name: 'Bomba Sur',
      type: DeviceType.bomba,
      status: DeviceStatus.critical,
      lastConnection: DateTime(2026, 8, 1, 8),
      sensorCount: 2,
      keySensors: const [],
    ),
    Device(
      id: 'device-motor-backup',
      siteId: 'site-1',
      name: 'Motor Backup',
      type: DeviceType.motor,
      status: DeviceStatus.offline,
      lastConnection: DateTime(2026, 8, 1, 2),
      sensorCount: 2,
      keySensors: const [],
    ),
  ];

  setUp(() {
    dataSource = MockMockDeviceDataSource();
    when(() => dataSource.currentDevices).thenReturn(devices);
    repository = MockAlertRepositoryImpl(dataSource);
  });

  group('getAlerts', () {
    test('devuelve entre 6 y 8 alertas de fábrica', () async {
      final result = await repository.getAlerts();

      final alerts = (result as Right<Failure, List<Alert>>).value;
      expect(alerts.length, inInclusiveRange(6, 8));
    });

    test(
      'resuelve deviceName contra los devices de MockDeviceDataSource',
      () async {
        final result = await repository.getAlerts();
        final alerts = (result as Right<Failure, List<Alert>>).value;

        for (final alert in alerts) {
          final device = devices.firstWhere((d) => d.id == alert.deviceId);
          expect(alert.deviceName, device.name);
        }
      },
    );

    test('incluye al menos una alerta de cada severidad', () async {
      final result = await repository.getAlerts();
      final alerts = (result as Right<Failure, List<Alert>>).value;

      for (final severity in AlertSeverity.values) {
        expect(alerts.any((a) => a.severity == severity), isTrue);
      }
    });

    test('incluye al menos una alerta de cada estado', () async {
      final result = await repository.getAlerts();
      final alerts = (result as Right<Failure, List<Alert>>).value;

      for (final status in AlertStatus.values) {
        expect(alerts.any((a) => a.status == status), isTrue);
      }
    });

    test('incluye alertas con y sin sensorId', () async {
      final result = await repository.getAlerts();
      final alerts = (result as Right<Failure, List<Alert>>).value;

      expect(alerts.any((a) => a.sensorId == null), isTrue);
      expect(alerts.any((a) => a.sensorId != null), isTrue);
    });

    test('ningún device online tiene una alerta activa', () async {
      final result = await repository.getAlerts();
      final alerts = (result as Right<Failure, List<Alert>>).value;

      final onlineDeviceIds = devices
          .where((d) => d.status == DeviceStatus.online)
          .map((d) => d.id);

      for (final deviceId in onlineDeviceIds) {
        final hasActive = alerts.any(
          (a) => a.deviceId == deviceId && a.status == AlertStatus.active,
        );
        expect(hasActive, isFalse);
      }
    });
  });

  group('acknowledgeAlert', () {
    test(
      'con un id activo existente devuelve Right con status acknowledged',
      () async {
        final loaded = await repository.getAlerts();
        final activeAlert = (loaded as Right<Failure, List<Alert>>).value
            .firstWhere((a) => a.status == AlertStatus.active);

        final result = await repository.acknowledgeAlert(activeAlert.id);

        final updated = (result as Right<Failure, Alert>).value;
        expect(updated.id, activeAlert.id);
        expect(updated.status, AlertStatus.acknowledged);
      },
    );

    test('con un id inexistente devuelve Left(NotFoundFailure)', () async {
      final result = await repository.acknowledgeAlert('alert-no-existe');

      expect(result, isA<Left<Failure, Alert>>());
      expect((result as Left<Failure, Alert>).value, isA<NotFoundFailure>());
    });

    test('sobre una alerta ya acknowledged es un no-op idempotente', () async {
      final loaded = await repository.getAlerts();
      final alreadyAcknowledged = (loaded as Right<Failure, List<Alert>>).value
          .firstWhere((a) => a.status == AlertStatus.acknowledged);

      final result = await repository.acknowledgeAlert(alreadyAcknowledged.id);

      final returned = (result as Right<Failure, Alert>).value;
      expect(returned.status, AlertStatus.acknowledged);
      expect(returned.id, alreadyAcknowledged.id);
    });
  });
}
