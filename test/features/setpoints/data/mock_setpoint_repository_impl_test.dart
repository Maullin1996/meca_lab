import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/setpoints/data/repositories/mock_setpoint_repository_impl.dart';
import 'package:meca_lab/features/setpoints/domain/entities/setpoint.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/domain/entities/user_role.dart';

void main() {
  // Real MockDeviceDataSource (not a mocktail double) — the whole point of
  // these tests is verifying that updateSetpoint mutates the *actual*
  // shared Sensor.safeMin/safeMax, not a parallel copy.
  late MockDeviceDataSource dataSource;
  late MockSetpointRepositoryImpl repository;

  const knownSensorId = 'sensor-compresor-norte-temp';

  setUp(() {
    dataSource = MockDeviceDataSource();
    repository = MockSetpointRepositoryImpl(dataSource);
  });

  tearDown(() => dataSource.dispose());

  group('getSetpointForSensor', () {
    test('con sensor existente devuelve Right con los valores reales del sensor', () async {
      final result = await repository.getSetpointForSensor(knownSensorId);

      final setpoint = (result as Right<Failure, Setpoint>).value;
      final sensor = dataSource.findSensorById(knownSensorId)!;
      expect(setpoint.sensorId, knownSensorId);
      expect(setpoint.deviceId, sensor.deviceId);
      expect(setpoint.min, sensor.safeMin);
      expect(setpoint.max, sensor.safeMax);
      expect(setpoint.unit, sensor.unit);
      expect(setpoint.updatedBy, isNotEmpty);
    });

    test('con sensor inexistente devuelve Left(NotFoundFailure)', () async {
      final result = await repository.getSetpointForSensor('sensor-no-existe');

      expect(result, isA<Left<Failure, Setpoint>>());
      expect(
        (result as Left<Failure, Setpoint>).value,
        isA<NotFoundFailure>(),
      );
    });
  });

  group('updateSetpoint', () {
    test(
      'con rol administrador y rango válido devuelve Right y muta el sensor real',
      () async {
        final result = await repository.updateSetpoint(
          sensorId: knownSensorId,
          min: 15,
          max: 95,
          requestingRole: UserRole.administrador,
          requestingUserDisplayName: 'Ana Torres',
        );

        final setpoint = (result as Right<Failure, Setpoint>).value;
        expect(setpoint.min, 15);
        expect(setpoint.max, 95);
        expect(setpoint.updatedBy, 'Ana Torres');

        final sensor = dataSource.findSensorById(knownSensorId)!;
        expect(sensor.safeMin, 15);
        expect(sensor.safeMax, 95);
      },
    );

    test(
      'con rol operador devuelve Left(UnauthorizedFailure) y no muta el sensor',
      () async {
        final before = dataSource.findSensorById(knownSensorId)!;

        final result = await repository.updateSetpoint(
          sensorId: knownSensorId,
          min: 15,
          max: 95,
          requestingRole: UserRole.operador,
          requestingUserDisplayName: 'Camila Ríos',
        );

        expect(result, isA<Left<Failure, Setpoint>>());
        expect(
          (result as Left<Failure, Setpoint>).value,
          isA<UnauthorizedFailure>(),
        );

        final after = dataSource.findSensorById(knownSensorId)!;
        expect(after.safeMin, before.safeMin);
        expect(after.safeMax, before.safeMax);
      },
    );

    test(
      'con min >= max devuelve Left(ValidationFailure) y no muta el sensor',
      () async {
        final before = dataSource.findSensorById(knownSensorId)!;

        final result = await repository.updateSetpoint(
          sensorId: knownSensorId,
          min: 95,
          max: 95,
          requestingRole: UserRole.administrador,
          requestingUserDisplayName: 'Ana Torres',
        );

        expect(result, isA<Left<Failure, Setpoint>>());
        expect(
          (result as Left<Failure, Setpoint>).value,
          isA<ValidationFailure>(),
        );

        final after = dataSource.findSensorById(knownSensorId)!;
        expect(after.safeMin, before.safeMin);
        expect(after.safeMax, before.safeMax);
      },
    );

    test('con sensorId inexistente devuelve Left(NotFoundFailure)', () async {
      final result = await repository.updateSetpoint(
        sensorId: 'sensor-no-existe',
        min: 10,
        max: 20,
        requestingRole: UserRole.administrador,
        requestingUserDisplayName: 'Ana Torres',
      );

      expect(result, isA<Left<Failure, Setpoint>>());
      expect(
        (result as Left<Failure, Setpoint>).value,
        isA<NotFoundFailure>(),
      );
    });
  });
}
