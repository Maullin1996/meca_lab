import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../domain/entities/device.dart';

/// Shared between `dashboard` (device cards) and `device_detail` (screen
/// header) — the second real consumer that promoted it out of
/// `dashboard/presentation/widgets`.
class DeviceStatusBadge extends StatelessWidget {
  final DeviceStatus status;

  const DeviceStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    final (color, label) = switch (status) {
      DeviceStatus.online => (colors.success, 'Online'),
      DeviceStatus.warning => (colors.warning, 'Warning'),
      DeviceStatus.critical => (colors.error, 'Critical'),
      DeviceStatus.offline => (colors.textDisabled, 'Offline'),
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
