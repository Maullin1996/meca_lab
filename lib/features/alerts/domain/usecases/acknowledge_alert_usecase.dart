import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/alert.dart';
import '../repositories/alert_repository.dart';

class AcknowledgeAlertUseCase {
  final AlertRepository repository;

  const AcknowledgeAlertUseCase(this.repository);

  Future<Either<Failure, Alert>> call(String alertId) {
    return repository.acknowledgeAlert(alertId);
  }
}
