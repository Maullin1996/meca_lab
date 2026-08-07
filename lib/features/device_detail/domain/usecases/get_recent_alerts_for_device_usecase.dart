import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/alert.dart';
import '../../../../shared/domain/repositories/alert_repository.dart';

/// Exclusive to `device_detail` — "qué cuenta como reciente y relevante para
/// esta pantalla" (activa, warning/critical, top 5 más recientes) es una
/// regla de negocio propia de esta pantalla, no algo que cualquier llamador
/// necesitaría igual (a diferencia de `WatchSensorHistoryUseCase`, que sí es
/// idéntico sin importar quién lo pida). Por eso el filtro/orden/límite vive
/// acá y no como un método nuevo en `AlertRepository` — extender esa interfaz
/// rompería su implementación mock existente sin necesidad real.
class GetRecentAlertsForDeviceUseCase {
  final AlertRepository repository;
  const GetRecentAlertsForDeviceUseCase(this.repository);

  Future<Either<Failure, List<Alert>>> call(String deviceId) async {
    final result = await repository.getAlerts();
    return result.map((alerts) {
      final filtered =
          alerts
              .where(
                (a) =>
                    a.deviceId == deviceId &&
                    a.status == AlertStatus.active &&
                    (a.severity == AlertSeverity.warning ||
                        a.severity == AlertSeverity.critical),
              )
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filtered.take(5).toList();
    });
  }
}
