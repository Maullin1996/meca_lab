import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/alert.dart';

/// Exclusive to `alerts` for now — same dot+label pattern as
/// `DeviceStatusBadge` (`shared/widgets/`), but stays feature-local until a
/// second feature actually needs it (second-consumer rule).
class AlertSeverityBadge extends StatelessWidget {
  final AlertSeverity severity;

  const AlertSeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    final (color, label) = switch (severity) {
      AlertSeverity.info => (colors.info, 'Info'),
      AlertSeverity.warning => (colors.warning, 'Warning'),
      AlertSeverity.critical => (colors.error, 'Critical'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: tokens.spacing.xSmall),
        AppText.caption(label, color: color),
      ],
    );
  }
}
