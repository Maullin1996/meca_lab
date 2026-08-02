import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

class GetAlertsUseCase {
  final AlertRepository repository;

  const GetAlertsUseCase(this.repository);

  Future<Either<Failure, List<Alert>>> call() {
    return repository.getAlerts();
  }
}
