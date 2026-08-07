import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../shared/domain/entities/alert.dart';
import '../../../../shared/widgets/alert_severity_badge.dart';
import '../controllers/device_recent_alerts_controller.dart';

/// Replaces `RecentAlertsPlaceholder` now that `alerts` exists. Read-only —
/// no "Reconocer" here, that only lives on `AlertsPage` (reached via "Ver
/// todas"). Watches [deviceRecentAlertsProvider] directly, same pattern as
/// `SensorHistoryDetailChart` watching its own history provider, instead of
/// being threaded through `DeviceDetailViewData`.
class DeviceRecentAlertsSection extends ConsumerWidget {
  final String deviceId;

  const DeviceRecentAlertsSection({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final alertsAsync = ref.watch(deviceRecentAlertsProvider(deviceId));
    final alerts = alertsAsync.value ?? const <Alert>[];

    final listType = alertsAsync.when(
      data: (value) => value.isEmpty ? CardListType.empty : CardListType.list,
      loading: () => CardListType.loading,
      error: (error, stackTrace) => CardListType.error,
    );

    void handleViewAll() => context.push(AppRoutes.alerts);
    void handleRetry() => ref.invalidate(deviceRecentAlertsProvider(deviceId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: AppText.h6(
                'Alertas recientes',
                color: colors.textPrimary,
                maxLines: 1,
              ),
            ),
            AppButtons(
              type: ButtonType.primaryTextButton,
              title: AppText.body('Ver todas', color: colors.primary),
              onPressed: handleViewAll,
            ),
          ],
        ),
        SizedBox(height: tokens.spacing.xSmall),
        SizedBox(
          height: 260,
          child: AppCardList(
            type: listType,
            itemCount: alerts.length,
            itemBuilder: (context, index) =>
                _RecentAlertTile(alert: alerts[index]),
            emptyWidget: AppStateWidget(
              type: AppStateType.empty,
              icon: AppIcons.notification,
              title: 'Sin alertas activas',
              buttonChild: const Text('Ver todas'),
              onPressed: handleViewAll,
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
    );
  }
}

class _RecentAlertTile extends StatelessWidget {
  final Alert alert;

  const _RecentAlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.all(tokens.spacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlertSeverityBadge(severity: alert.severity),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.body(alert.message, color: colors.textSecondary, maxLines: 2),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.caption(
            _formatTimestamp(alert.timestamp),
            color: colors.textDisabled,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(timestamp.day)}/${two(timestamp.month)}/${timestamp.year} '
        '${two(timestamp.hour)}:${two(timestamp.minute)}';
  }
}
