import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/alerts/domain/usecases/get_alerts_usecase.dart';
import 'package:meca_lab/shared/domain/entities/alert.dart';
import 'package:meca_lab/shared/domain/repositories/alert_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late MockAlertRepository repository;
  late GetAlertsUseCase useCase;

  setUp(() {
    repository = MockAlertRepository();
    useCase = GetAlertsUseCase(repository);
  });

  final alerts = [
    Alert(
      id: 'alert-1',
      deviceId: 'device-1',
      deviceName: 'Compresor A1',
      sensorId: 'sensor-1',
      severity: AlertSeverity.warning,
      message: 'Temperatura por encima del rango seguro',
      timestamp: DateTime(2026, 8, 1, 10),
      status: AlertStatus.active,
    ),
  ];

  test('devuelve Right(List<Alert>) cuando la carga es exitosa', () async {
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    final result = await useCase();

    expect(result, Right<Failure, List<Alert>>(alerts));
    verify(() => repository.getAlerts()).called(1);
  });

  test('propaga Left(Failure) cuando el repositorio falla', () async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('error mock')));

    final result = await useCase();

    expect(
      result,
      const Left<Failure, List<Alert>>(UnexpectedFailure('error mock')),
    );
  });
}
