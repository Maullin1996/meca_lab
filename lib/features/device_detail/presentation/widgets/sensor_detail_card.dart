import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/sensor.dart';
import '../../../../shared/widgets/sensor_history_chart.dart';

/// Exclusive to `device_detail` — shared between its mobile and web views
/// (level-3 reuse per the skill's widget-reuse ladder), not a
/// `lib/shared/widgets/` candidate since no other feature needs it. The
/// chart itself (`SensorHistoryChart`) is shared — this card is just the
/// device_detail-specific composition around it.
class SensorDetailCard extends StatelessWidget {
  final Sensor sensor;

  /// Whether the sensor's device is online — forwarded to
  /// [SensorHistoryChart] so an offline device's chart doesn't look live.
  final bool isLive;

  const SensorDetailCard({
    super.key,
    required this.sensor,
    this.isLive = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.all(tokens.spacing.small),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h6(sensor.name, color: colors.textPrimary, maxLines: 1),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.bodyLg(
            '${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}',
            color: colors.textPrimary,
          ),
          SizedBox(height: tokens.spacing.small),
          SensorHistoryChart(sensorId: sensor.id, isLive: isLive),
        ],
      ),
    );
  }
}
