import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/alert.dart';
import '../../../../shared/widgets/alert_severity_badge.dart';

class AlertListItem extends StatelessWidget {
  final Alert alert;

  /// `null` hides the "Reconocer" button entirely — the page only passes a
  /// callback for `active` alerts, since acknowledging an already
  /// acknowledged/resolved alert has nothing to invite the user to do.
  final VoidCallback? onAcknowledge;

  const AlertListItem({super.key, required this.alert, this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.all(tokens.spacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AlertSeverityBadge(severity: alert.severity),
              AppText.caption(
                _statusLabel(alert.status),
                color: colors.textSecondary,
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.body(
            alert.deviceName,
            color: colors.textPrimary,
            maxLines: 1,
          ),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.body(alert.message, color: colors.textSecondary, maxLines: 3),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.caption(
            _formatTimestamp(alert.timestamp),
            color: colors.textDisabled,
          ),
          if (onAcknowledge != null) ...[
            SizedBox(height: tokens.spacing.xSmall),
            Align(
              alignment: Alignment.centerRight,
              child: AppButtons(
                key: Key('acknowledge-${alert.id}'),
                type: ButtonType.primaryTextButton,
                title: AppText.body('Reconocer', color: colors.primary),
                onPressed: onAcknowledge,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(AlertStatus status) => switch (status) {
    AlertStatus.active => 'Activa',
    AlertStatus.acknowledged => 'Reconocida',
    AlertStatus.resolved => 'Resuelta',
  };

  String _formatTimestamp(DateTime timestamp) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(timestamp.day)}/${two(timestamp.month)}/${timestamp.year} '
        '${two(timestamp.hour)}:${two(timestamp.minute)}';
  }
}
