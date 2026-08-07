import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/alert.dart';
import '../../../../shared/domain/repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;

  const GetAlertsUseCase(this.repository);

  Future<Either<Failure, List<Alert>>> call() {
    return repository.getAlerts();
  }
}
