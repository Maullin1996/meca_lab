import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/setpoints/domain/entities/setpoint.dart';
import 'package:meca_lab/features/setpoints/domain/repositories/setpoint_repository.dart';
import 'package:meca_lab/features/setpoints/domain/usecases/update_setpoint_usecase.dart';
import 'package:meca_lab/shared/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockSetpointRepository extends Mock implements SetpointRepository {}

void main() {
  late MockSetpointRepository repository;
  late UpdateSetpointUseCase useCase;

  setUp(() {
    repository = MockSetpointRepository();
    useCase = UpdateSetpointUseCase(repository);
  });

  final updatedSetpoint = Setpoint(
    id: 'setpoint-1',
    deviceId: 'device-1',
    sensorId: 'sensor-1',
    min: 15,
    max: 95,
    unit: '°C',
    updatedBy: 'Andrés Torres',
    updatedAt: DateTime(2026, 8, 1, 10),
  );

  test('con rol administrador devuelve Right(Setpoint) actualizado', () async {
    when(
      () => repository.updateSetpoint(
        sensorId: 'sensor-1',
        min: 15,
        max: 95,
        requestingRole: UserRole.administrador,
        requestingUserDisplayName: 'Test User',
      ),
    ).thenAnswer((_) async => Right(updatedSetpoint));

    final result = await useCase(
      sensorId: 'sensor-1',
      min: 15,
      max: 95,
      requestingRole: UserRole.administrador,
      requestingUserDisplayName: 'Test User',
    );

    expect(result, Right<Failure, Setpoint>(updatedSetpoint));
    verify(
      () => repository.updateSetpoint(
        sensorId: 'sensor-1',
        min: 15,
        max: 95,
        requestingRole: UserRole.administrador,
        requestingUserDisplayName: 'Test User',
      ),
    ).called(1);
  });

  test('con rol operador propaga Left(UnauthorizedFailure)', () async {
    when(
      () => repository.updateSetpoint(
        sensorId: 'sensor-1',
        min: 15,
        max: 95,
        requestingRole: UserRole.operador,
        requestingUserDisplayName: 'Test User',
      ),
    ).thenAnswer(
      (_) async => const Left(
        UnauthorizedFailure('solo un administrador puede editar setpoints'),
      ),
    );

    final result = await useCase(
      sensorId: 'sensor-1',
      min: 15,
      max: 95,
      requestingRole: UserRole.operador,
      requestingUserDisplayName: 'Test User',
    );

    expect(result, isA<Left<Failure, Setpoint>>());
    expect(
      (result as Left<Failure, Setpoint>).value,
      isA<UnauthorizedFailure>(),
    );
  });
}
