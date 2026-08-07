import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/alert.dart';
import '../controllers/alerts_controller.dart';
import '../widgets/alert_list_item.dart';

/// A filterable list doesn't change *shape* between mobile and web (unlike
/// dashboard's grid or device_detail's header) — one responsive page,
/// connected directly to [AlertsController], instead of the
/// `_page`/`_mobile_view`/`_web_view` split used elsewhere.
class AlertsPage extends ConsumerWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final alertsAsync = ref.watch(alertsControllerProvider);
    final state = alertsAsync.value;
    final alerts = state?.filteredAlerts ?? const <Alert>[];

    final listType = alertsAsync.when(
      data: (value) =>
          value.filteredAlerts.isEmpty ? CardListType.empty : CardListType.list,
      loading: () => CardListType.loading,
      error: (error, stackTrace) => CardListType.error,
    );

    Future<void> handleAcknowledge(String alertId) async {
      final errorMessage = await ref
          .read(alertsControllerProvider.notifier)
          .acknowledgeAlert(alertId);
      if (!context.mounted) return;
      if (errorMessage == null) {
        AppSnackBar.show(
          context,
          type: SnackBarType.success,
          message: 'Alerta reconocida.',
        );
      } else {
        AppSnackBar.show(
          context,
          type: SnackBarType.error,
          message: errorMessage,
        );
      }
    }

    void handleRetry() => ref.invalidate(alertsControllerProvider);

    void handleClearFilters() {
      ref.read(alertsControllerProvider.notifier).setSeverityFilter(null);
      ref.read(alertsControllerProvider.notifier).setStatusFilter(null);
    }

    return Scaffold(
      appBar: AppBar(title: AppText.h6('Alertas', color: colors.primary)),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.small),
          child: Column(
            children: [
              _AlertFilters(
                state: state,
                onSeverityChanged: (severity) => ref
                    .read(alertsControllerProvider.notifier)
                    .setSeverityFilter(severity),
                onStatusChanged: (status) => ref
                    .read(alertsControllerProvider.notifier)
                    .setStatusFilter(status),
              ),
              SizedBox(height: tokens.spacing.small),
              Expanded(
                child: AppCardList(
                  type: listType,
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return AlertListItem(
                      key: ValueKey(alert.id),
                      alert: alert,
                      onAcknowledge: alert.status == AlertStatus.active
                          ? () => handleAcknowledge(alert.id)
                          : null,
                    );
                  },
                  emptyWidget: AppStateWidget(
                    type: AppStateType.empty,
                    icon: AppIcons.information,
                    title: 'Ninguna alerta coincide con los filtros',
                    buttonChild: const Text('Limpiar filtros'),
                    onPressed: handleClearFilters,
                  ),
                  errorWidget: AppStateWidget(
                    type: AppStateType.error,
                    icon: AppIcons.error,
                    title: 'No pudimos cargar las alertas',
                    buttonChild: const Text('Reintentar'),
                    onPressed: handleRetry,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertFilters extends StatelessWidget {
  final AlertsState? state;
  final ValueChanged<AlertSeverity?> onSeverityChanged;
  final ValueChanged<AlertStatus?> onStatusChanged;

  const _AlertFilters({
    required this.state,
    required this.onSeverityChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);

    return Wrap(
      spacing: tokens.spacing.xSmall,
      runSpacing: tokens.spacing.xSmall,
      children: [
        for (final severity in AlertSeverity.values)
          AppFilterChip(
            key: Key('severity-filter-${severity.name}'),
            label: _severityLabel(severity),
            selected: state?.severityFilter == severity,
            onSelected: (selected) =>
                onSeverityChanged(selected ? severity : null),
          ),
        for (final status in AlertStatus.values)
          AppFilterChip(
            key: Key('status-filter-${status.name}'),
            label: _statusLabel(status),
            selected: state?.statusFilter == status,
            onSelected: (selected) => onStatusChanged(selected ? status : null),
          ),
      ],
    );
  }

  String _severityLabel(AlertSeverity severity) => switch (severity) {
    AlertSeverity.info => 'Info',
    AlertSeverity.warning => 'Warning',
    AlertSeverity.critical => 'Critical',
  };

  String _statusLabel(AlertStatus status) => switch (status) {
    AlertStatus.active => 'Activa',
    AlertStatus.acknowledged => 'Reconocida',
    AlertStatus.resolved => 'Resuelta',
  };
}
