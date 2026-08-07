import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/domain/usecases/get_recent_alerts_for_device_usecase.dart';
import 'package:meca_lab/shared/domain/entities/alert.dart';
import 'package:meca_lab/shared/domain/repositories/alert_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late MockAlertRepository repository;
  late GetRecentAlertsForDeviceUseCase useCase;

  setUp(() {
    repository = MockAlertRepository();
    useCase = GetRecentAlertsForDeviceUseCase(repository);
  });

  Alert buildAlert({
    required String id,
    String deviceId = 'dev-1',
    AlertSeverity severity = AlertSeverity.warning,
    AlertStatus status = AlertStatus.active,
    required DateTime timestamp,
  }) => Alert(
    id: id,
    deviceId: deviceId,
    deviceName: 'Compresor Norte',
    severity: severity,
    message: 'Mensaje de prueba',
    timestamp: timestamp,
    status: status,
  );

  test('excluye alertas de otros devices', () async {
    final alerts = [
      buildAlert(id: 'a1', deviceId: 'dev-2', timestamp: DateTime(2026, 8, 1)),
      buildAlert(id: 'a2', deviceId: 'dev-1', timestamp: DateTime(2026, 8, 2)),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase('dev-1');

    final recent = (result as Right<Failure, List<Alert>>).value;
    expect(recent.map((a) => a.id), ['a2']);
  });

  test('excluye alertas info activas', () async {
    final alerts = [
      buildAlert(
        id: 'a1',
        severity: AlertSeverity.info,
        timestamp: DateTime(2026, 8, 1),
      ),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase('dev-1');

    final recent = (result as Right<Failure, List<Alert>>).value;
    expect(recent, isEmpty);
  });

  test('excluye alertas warning/critical que no están activas', () async {
    final alerts = [
      buildAlert(
        id: 'a1',
        severity: AlertSeverity.warning,
        status: AlertStatus.acknowledged,
        timestamp: DateTime(2026, 8, 1),
      ),
      buildAlert(
        id: 'a2',
        severity: AlertSeverity.critical,
        status: AlertStatus.resolved,
        timestamp: DateTime(2026, 8, 2),
      ),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase('dev-1');

    final recent = (result as Right<Failure, List<Alert>>).value;
    expect(recent, isEmpty);
  });

  test('con más de 5 candidatas recorta a 5, más recientes primero', () async {
    final alerts = [
      for (var i = 0; i < 8; i++)
        buildAlert(
          id: 'a$i',
          severity: i.isEven ? AlertSeverity.warning : AlertSeverity.critical,
          timestamp: DateTime(2026, 8, 1).add(Duration(hours: i)),
        ),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase('dev-1');

    final recent = (result as Right<Failure, List<Alert>>).value;
    expect(recent.length, 5);
    expect(recent.map((a) => a.id), ['a7', 'a6', 'a5', 'a4', 'a3']);
  });

  test('caso feliz: alertas activas warning/critical del device, recientes primero', () async {
    final alerts = [
      buildAlert(
        id: 'a1',
        severity: AlertSeverity.warning,
        timestamp: DateTime(2026, 8, 1, 8),
      ),
      buildAlert(
        id: 'a2',
        severity: AlertSeverity.critical,
        timestamp: DateTime(2026, 8, 1, 10),
      ),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase('dev-1');

    final recent = (result as Right<Failure, List<Alert>>).value;
    expect(recent.map((a) => a.id), ['a2', 'a1']);
  });

  test('propaga Left(Failure) cuando el repositorio falla', () async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('boom')));

    final result = await useCase('dev-1');

    expect(
      result,
      const Left<Failure, List<Alert>>(UnexpectedFailure('boom')),
    );
  });
}
