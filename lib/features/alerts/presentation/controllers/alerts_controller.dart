import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/data/repositories/mock_alert_repository_impl.dart';
import '../../../../shared/domain/entities/alert.dart';
import '../../domain/usecases/acknowledge_alert_usecase.dart';
import '../../domain/usecases/get_alerts_usecase.dart';

part 'alerts_controller.g.dart';

/// Plain state exposed to `presentation` widgets — no `Either`/`Failure`
/// leaks past this point. Severity/status filters are the controller's own
/// state (not use-case parameters), applied over the already-loaded list by
/// [filteredAlerts] — same criterion as `dashboard`'s search filter.
class AlertsState {
  final List<Alert> alerts;
  final AlertSeverity? severityFilter;
  final AlertStatus? statusFilter;

  const AlertsState({
    required this.alerts,
    this.severityFilter,
    this.statusFilter,
  });

  List<Alert> get filteredAlerts => alerts.where((alert) {
    final matchesSeverity =
        severityFilter == null || alert.severity == severityFilter;
    final matchesStatus = statusFilter == null || alert.status == statusFilter;
    return matchesSeverity && matchesStatus;
  }).toList();
}

/// A repository failure here isn't transient (the mock doesn't recover), so
/// retrying is just wasted work — same reasoning as `DashboardController`.
Duration? _neverRetry(int retryCount, Object error) => null;

/// The only place in `presentation` that touches `Either`/`fpdart`.
@Riverpod(retry: _neverRetry)
class AlertsController extends _$AlertsController {
  @override
  FutureOr<AlertsState> build() async {
    final repository = ref.watch(alertRepositoryImplProvider);
    final result = await GetAlertsUseCase(repository)();

    return result.fold(
      (failure) => throw failure,
      (alerts) => AlertsState(alerts: alerts),
    );
  }

  void setSeverityFilter(AlertSeverity? severity) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      AlertsState(
        alerts: current.alerts,
        severityFilter: severity,
        statusFilter: current.statusFilter,
      ),
    );
  }

  void setStatusFilter(AlertStatus? status) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(
      AlertsState(
        alerts: current.alerts,
        severityFilter: current.severityFilter,
        statusFilter: status,
      ),
    );
  }

  /// Acknowledges [alertId] and patches it in place within the already
  /// loaded list — never refetches the whole list via [GetAlertsUseCase].
  /// Returns `null` on success, or a user-facing error message on failure
  /// (never the raw [NotFoundFailure.message]) for the page to show in an
  /// `AppSnackBar`.
  Future<String?> acknowledgeAlert(String alertId) async {
    final current = state.value;
    if (current == null) return null;

    final repository = ref.read(alertRepositoryImplProvider);
    final result = await AcknowledgeAlertUseCase(repository)(alertId);

    return result.fold(_messageFor, (updatedAlert) {
      state = AsyncValue.data(
        AlertsState(
          alerts: [
            for (final alert in current.alerts)
              if (alert.id == updatedAlert.id) updatedAlert else alert,
          ],
          severityFilter: current.severityFilter,
          statusFilter: current.statusFilter,
        ),
      );
      return null;
    });
  }

  String _messageFor(Failure failure) {
    return switch (failure) {
      NotFoundFailure() =>
        'No pudimos encontrar esa alerta. Es posible que ya no exista.',
      InvalidCredentialsFailure() => 'Email o contraseña incorrectos.',
      NoSessionFailure() => 'No hay una sesión activa.',
      UnauthorizedFailure() => 'No tienes permisos para realizar esta acción.',
      UnexpectedFailure(:final message) =>
        'Ocurrió un error inesperado: $message',
    };
  }
}
