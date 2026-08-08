import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/data/datasources/mock_device_data_source.dart';
import '../../../../shared/domain/entities/user_role.dart';
import '../../domain/entities/setpoint.dart';
import '../../domain/repositories/setpoint_repository.dart';

part 'mock_setpoint_repository_impl.g.dart';

/// Reads/writes directly on `MockDeviceDataSource`'s `Sensor.safeMin`/
/// `safeMax` — no parallel copy of the range lives here. The only state
/// this class keeps for itself is the audit trail (`updatedBy`/
/// `updatedAt`), since `Sensor` has nowhere to carry that.
class MockSetpointRepositoryImpl implements SetpointRepository {
  MockSetpointRepositoryImpl(this.dataSource);

  final MockDeviceDataSource dataSource;

  /// Audit metadata per sensor, seeded lazily with factory defaults the
  /// first time a sensor's setpoint is read/written, not eagerly for every
  /// sensor at construction — most setpoints are never touched in a demo
  /// session.
  final Map<String, ({String updatedBy, DateTime updatedAt})> _audit = {};

  /// Factory-provisioning timestamp shared by every sensor's first audit
  /// read — computed once per repository instance so it stays stable for
  /// the life of the session instead of drifting closer to "now" on every
  /// read.
  final DateTime _factoryProvisionedAt = DateTime.now().subtract(
    const Duration(days: 30),
  );

  ({String updatedBy, DateTime updatedAt}) _auditFor(String sensorId) =>
      _audit.putIfAbsent(
        sensorId,
        () => (
          updatedBy: 'Configuración inicial de fábrica',
          updatedAt: _factoryProvisionedAt,
        ),
      );

  @override
  Future<Either<Failure, Setpoint>> getSetpointForSensor(
    String sensorId,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final sensor = dataSource.findSensorById(sensorId);
    if (sensor == null) {
      return Left(NotFoundFailure('sensor not found: $sensorId'));
    }

    final audit = _auditFor(sensorId);
    return Right(
      Setpoint(
        id: 'setpoint-$sensorId',
        deviceId: sensor.deviceId,
        sensorId: sensor.id,
        min: sensor.safeMin,
        max: sensor.safeMax,
        unit: sensor.unit,
        updatedBy: audit.updatedBy,
        updatedAt: audit.updatedAt,
      ),
    );
  }

  @override
  Future<Either<Failure, Setpoint>> updateSetpoint({
    required String sensorId,
    required double min,
    required double max,
    required UserRole requestingRole,
    required String requestingUserDisplayName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (requestingRole != UserRole.administrador) {
      return const Left(
        UnauthorizedFailure('Solo un administrador puede editar setpoints.'),
      );
    }

    final sensor = dataSource.findSensorById(sensorId);
    if (sensor == null) {
      return Left(NotFoundFailure('sensor not found: $sensorId'));
    }

    if (min >= max) {
      return const Left(
        ValidationFailure('El valor mínimo debe ser menor que el máximo.'),
      );
    }

    dataSource.updateSensorSafeRange(sensorId, min, max);
    final updatedAt = DateTime.now();
    _audit[sensorId] = (updatedBy: requestingUserDisplayName, updatedAt: updatedAt);

    return Right(
      Setpoint(
        id: 'setpoint-$sensorId',
        deviceId: sensor.deviceId,
        sensorId: sensor.id,
        min: min,
        max: max,
        unit: sensor.unit,
        updatedBy: requestingUserDisplayName,
        updatedAt: updatedAt,
      ),
    );
  }
}

@Riverpod(keepAlive: true)
SetpointRepository setpointRepositoryImpl(Ref ref) {
  final dataSource = ref.watch(mockDeviceDataSourceProvider);
  return MockSetpointRepositoryImpl(dataSource);
}
