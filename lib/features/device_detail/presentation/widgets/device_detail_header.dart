import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';
import '../../../../shared/widgets/device_status_badge.dart';
import '../../domain/entities/device_detail.dart';

/// Exclusive to `device_detail` — shared between its mobile and web views.
/// The device name itself lives in each view's `AppBar` title, so this only
/// covers status + type + last connection.
class DeviceDetailHeader extends StatelessWidget {
  final DeviceDetail deviceDetail;

  const DeviceDetailHeader({super.key, required this.deviceDetail});

  String get _typeLabel => switch (deviceDetail.device.type) {
    DeviceType.compresor => 'Compresor',
    DeviceType.motor => 'Motor',
    DeviceType.bomba => 'Bomba',
    DeviceType.banda => 'Banda transportadora',
  };

  String _formatLastConnection(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month $hour:$minute';
  }

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
            children: [
              DeviceStatusBadge(status: deviceDetail.device.status),
              SizedBox(width: tokens.spacing.small),
              Expanded(
                child: AppText.label(_typeLabel, color: colors.textSecondary),
              ),
            ],
          ),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.caption(
            'Última conexión: ${_formatLastConnection(deviceDetail.device.lastConnection)}',
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }
}
