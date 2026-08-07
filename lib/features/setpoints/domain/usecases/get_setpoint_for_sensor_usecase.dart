import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/setpoint.dart';
import '../repositories/setpoint_repository.dart';

class GetSetpointForSensorUseCase {
  final SetpointRepository repository;

  const GetSetpointForSensorUseCase(this.repository);

  Future<Either<Failure, Setpoint>> call(String sensorId) {
    return repository.getSetpointForSensor(sensorId);
  }
}
