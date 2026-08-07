import 'package:fpdart/fpdart.dart';

import '../../../core/error/failures.dart';
import '../entities/alert.dart';

abstract class AlertRepository {
  Future<Either<Failure, List<Alert>>> getAlerts();

  /// Returns the updated [Alert] (status -> [AlertStatus.acknowledged]), not
  /// `void` — the controller can patch its local state without refetching
  /// the whole list.
  Future<Either<Failure, Alert>> acknowledgeAlert(String alertId);
}
