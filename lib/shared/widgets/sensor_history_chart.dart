import 'package:atomic_design/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../presentation/controllers/sensor_history_controller.dart';

/// [ChartVariant.full] is meant for `device_detail`'s larger sensor cards —
/// a light grid + border for a "real chart" feel. [ChartVariant.compact] is
/// meant for `dashboard`'s tight device cards — just the trend line, no
/// titles/grid/border, so several fit per card.
enum ChartVariant { full, compact }

/// Shared between `dashboard` (one mini-chart per `Device.keySensors` entry)
/// and `device_detail` (one per full sensor) — the second real consumer
/// that promoted this out of `device_detail/presentation/widgets`.
///
/// Watches its own `sensorHistoryControllerProvider(sensorId)` independently
/// — each chart resolves its own history, it isn't handed down by a parent
/// page. Riverpod caches that provider per `sensorId`, so dashboard and
/// device_detail share the same stream for the same sensor instead of each
/// opening a second one.
class SensorHistoryChart extends ConsumerWidget {
  final String sensorId;
  final ChartVariant variant;

  /// Whether this sensor's device is currently online. When `false`, the
  /// chart renders the last known history in a muted color with no
  /// update animation, instead of looking like a live feed that has simply
  /// gone quiet.
  final bool isLive;

  const SensorHistoryChart({
    super.key,
    required this.sensorId,
    this.variant = ChartVariant.full,
    this.isLive = true,
  });

  bool get _isCompact => variant == ChartVariant.compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(sensorHistoryControllerProvider(sensorId));
    final colors = AppColors.of(context);
    final readings = historyState.value;

    final height = _isCompact ? 24.0 : 80.0;

    if (readings == null || readings.length < 2) {
      return SizedBox(height: height);
    }

    final lineColor = isLive ? colors.primary : colors.textDisabled;
    final spots = [
      for (var i = 0; i < readings.length; i++)
        FlSpot(i.toDouble(), readings[i].value),
    ];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: LineChart(
        duration: isLive
            ? const Duration(milliseconds: 150)
            : Duration.zero,
        LineChartData(
          titlesData: const FlTitlesData(show: false),
          gridData: FlGridData(
            show: !_isCompact,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: colors.divider, strokeWidth: 1),
          ),
          borderData: _isCompact
              ? FlBorderData(show: false)
              : FlBorderData(
                  show: true,
                  border: Border.all(color: colors.divider, width: 1),
                ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: _isCompact ? 1.5 : 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
