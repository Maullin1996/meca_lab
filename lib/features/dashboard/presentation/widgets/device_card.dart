import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';
import 'device_status_badge.dart';

/// Feature-scoped for now — becomes a `lib/shared/widgets/` candidate only
/// once `device_detail` needs the same card (second-consumer rule).
class DeviceCard extends StatelessWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  String get _typeLabel => switch (device.type) {
    DeviceType.compresor => 'Compresor',
    DeviceType.motor => 'Motor',
    DeviceType.bomba => 'Bomba',
    DeviceType.banda => 'Banda transportadora',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radius.medium),
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.all(tokens.spacing.small),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText.h6(device.name, color: colors.textPrimary, maxLines: 1),
            SizedBox(height: tokens.spacing.xSmall),
            DeviceStatusBadge(status: device.status),
            SizedBox(height: tokens.spacing.xSmall),
            AppText.label(_typeLabel, color: colors.textSecondary),
            const Spacer(),
            for (final sensor in device.keySensors)
              Padding(
                padding: EdgeInsets.only(top: tokens.spacing.xSmall),
                child: AppText.caption(
                  '${sensor.name}: ${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}',
                  color: colors.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
