import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/user_role.dart';
import '../entities/setpoint.dart';

/// Design note: the role check lives here, in the repository, not in
/// `UpdateSetpointUseCase`. The repository's `data/` implementation is what
/// actually mutates the shared `Sensor.safeMin`/`safeMax` on
/// `MockDeviceDataSource` — it's the layer with the real power to corrupt
/// shared state, so it shouldn't blindly trust that some caller already
/// validated the role upstream. A use case that forgot the check (or a
/// future second caller of this repository) would otherwise have no
/// enforcement left protecting the data.
abstract class SetpointRepository {
  Future<Either<Failure, Setpoint>> getSetpointForSensor(String sensorId);

  /// [requestingRole] must be [UserRole.administrador] — returns
  /// [UnauthorizedFailure] otherwise. [requestingUserDisplayName] becomes
  /// the returned [Setpoint.updatedBy] — the audit line's "quién".
  Future<Either<Failure, Setpoint>> updateSetpoint({
    required String sensorId,
    required double min,
    required double max,
    required UserRole requestingRole,
    required String requestingUserDisplayName,
  });
}
