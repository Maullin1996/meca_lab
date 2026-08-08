import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/sensor.dart';
import '../../../../shared/domain/entities/user_role.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../setpoints/presentation/widgets/setpoint_edit_sheet.dart';
import 'sensor_history_detail_chart.dart';

/// Exclusive to `device_detail` — shared between its mobile and web views
/// (level-3 reuse per the skill's widget-reuse ladder), not a
/// `lib/shared/widgets/` candidate since no other feature needs it. The
/// chart itself (`SensorHistoryDetailChart`) is also feature-exclusive —
/// unlike the compact one dashboard uses, this needs full axes, a
/// day/week/month range picker, and a hover tooltip.
///
/// `ConsumerWidget` (not `StatelessWidget`) only because it needs to read
/// the current user's role to decide whether the setpoint edit icon shows
/// — same criterion as `SensorHistoryDetailChart` reading its own provider
/// directly instead of being threaded through `DeviceDetailViewData`.
class SensorDetailCard extends ConsumerWidget {
  final Sensor sensor;

  /// Whether the sensor's device is online — forwarded to
  /// [SensorHistoryChart] so an offline device's chart doesn't look live.
  final bool isLive;

  const SensorDetailCard({super.key, required this.sensor, this.isLive = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final isAdmin =
        ref.watch(authControllerProvider).value?.user?.role ==
        UserRole.administrador;

    void handleEditSetpoint() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => SetpointEditSheet(sensorId: sensor.id),
      );
    }

    return AppCard(
      padding: EdgeInsets.all(tokens.spacing.smallMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText.h6(
                  sensor.name,
                  color: colors.textPrimary,
                  maxLines: 1,
                ),
              ),
              if (isAdmin)
                AppButtons(
                  type: ButtonType.primaryIconButton,
                  icon: AppIcons.edit,
                  iconSize: 20,
                  onPressed: handleEditSetpoint,
                ),
            ],
          ),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.bodyLg(
            '${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}',
            color: colors.textPrimary,
          ),
          SizedBox(height: tokens.spacing.small),
          SensorHistoryDetailChart(
            sensorId: sensor.id,
            unit: sensor.unit,
            isLive: isLive,
          ),
        ],
      ),
    );
  }
}
