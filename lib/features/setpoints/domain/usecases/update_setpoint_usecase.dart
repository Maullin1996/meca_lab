import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/user_role.dart';
import '../entities/setpoint.dart';
import '../repositories/setpoint_repository.dart';

/// Trusts [SetpointRepository] to enforce the role check — see the design
/// note on [SetpointRepository] for why it isn't duplicated here.
class UpdateSetpointUseCase {
  final SetpointRepository repository;

  const UpdateSetpointUseCase(this.repository);

  Future<Either<Failure, Setpoint>> call({
    required String sensorId,
    required double min,
    required double max,
    required UserRole requestingRole,
    required String requestingUserDisplayName,
  }) {
    return repository.updateSetpoint(
      sensorId: sensorId,
      min: min,
      max: max,
      requestingRole: requestingRole,
      requestingUserDisplayName: requestingUserDisplayName,
    );
  }
}
