import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/alerts/domain/entities/alert.dart';
import 'package:meca_lab/features/alerts/domain/repositories/alert_repository.dart';
import 'package:meca_lab/features/alerts/domain/usecases/acknowledge_alert_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late MockAlertRepository repository;
  late AcknowledgeAlertUseCase useCase;

  setUp(() {
    repository = MockAlertRepository();
    useCase = AcknowledgeAlertUseCase(repository);
  });

  final acknowledgedAlert = Alert(
    id: 'alert-1',
    deviceId: 'device-1',
    deviceName: 'Compresor A1',
    sensorId: 'sensor-1',
    severity: AlertSeverity.warning,
    message: 'Temperatura por encima del rango seguro',
    timestamp: DateTime(2026, 8, 1, 10),
    status: AlertStatus.acknowledged,
  );

  test('devuelve Right(Alert) actualizada cuando el ack es exitoso', () async {
    when(
      () => repository.acknowledgeAlert('alert-1'),
    ).thenAnswer((_) async => Right(acknowledgedAlert));

    final result = await useCase('alert-1');

    expect(result, Right<Failure, Alert>(acknowledgedAlert));
    verify(() => repository.acknowledgeAlert('alert-1')).called(1);
  });

  test('propaga Left(Failure) cuando el repositorio falla', () async {
    when(
      () => repository.acknowledgeAlert('alert-404'),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('no existe')));

    final result = await useCase('alert-404');

    expect(result, const Left<Failure, Alert>(UnexpectedFailure('no existe')));
  });
}
