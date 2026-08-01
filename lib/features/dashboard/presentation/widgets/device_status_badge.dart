import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';

/// Feature-scoped for now — becomes a `lib/shared/widgets/` candidate only
/// once `device_detail` needs the same badge (second-consumer rule).
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
