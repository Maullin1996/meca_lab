import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/setpoints/domain/entities/setpoint.dart';
import 'package:meca_lab/features/setpoints/domain/repositories/setpoint_repository.dart';
import 'package:meca_lab/features/setpoints/domain/usecases/get_setpoint_for_sensor_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockSetpointRepository extends Mock implements SetpointRepository {}

void main() {
  late MockSetpointRepository repository;
  late GetSetpointForSensorUseCase useCase;

  setUp(() {
    repository = MockSetpointRepository();
    useCase = GetSetpointForSensorUseCase(repository);
  });

  final setpoint = Setpoint(
    id: 'setpoint-1',
    deviceId: 'device-1',
    sensorId: 'sensor-1',
    min: 20,
    max: 90,
    unit: '°C',
    updatedBy: 'Andrés Torres',
    updatedAt: DateTime(2026, 8, 1, 10),
  );

  test('devuelve Right(Setpoint) cuando el sensor existe', () async {
    when(
      () => repository.getSetpointForSensor('sensor-1'),
    ).thenAnswer((_) async => Right(setpoint));

    final result = await useCase('sensor-1');

    expect(result, Right<Failure, Setpoint>(setpoint));
    verify(() => repository.getSetpointForSensor('sensor-1')).called(1);
  });

  test('devuelve Left(NotFoundFailure) si el sensor no existe', () async {
    when(() => repository.getSetpointForSensor('sensor-no-existe')).thenAnswer(
      (_) async =>
          const Left(NotFoundFailure('sensor not found: sensor-no-existe')),
    );

    final result = await useCase('sensor-no-existe');

    expect(result, isA<Left<Failure, Setpoint>>());
    expect(
      (result as Left<Failure, Setpoint>).value,
      isA<NotFoundFailure>(),
    );
  });
}
