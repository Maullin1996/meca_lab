import 'package:atomic_design/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/domain/entities/sensor_history_range.dart';
import '../../../../shared/domain/entities/sensor_reading.dart';
import '../controllers/sensor_history_range_controller.dart';

/// Exclusive to `device_detail` — deliberately NOT `SensorHistoryChart`
/// (`lib/shared/widgets/`, used by dashboard's compact mini-charts). This
/// screen needs real axis labels, a day/week/month range picker, and a
/// hover tooltip, none of which dashboard's tight grid cells have room for
/// or asked for — forcing them into the shared compact chart would change
/// dashboard's behavior, which this change explicitly must not touch.
class SensorHistoryDetailChart extends ConsumerStatefulWidget {
  final String sensorId;
  final String unit;

  /// Whether the sensor's device is online — dims the line color when not,
  /// same visual language as `SensorHistoryChart`'s `isLive`.
  final bool isLive;

  const SensorHistoryDetailChart({
    super.key,
    required this.sensorId,
    required this.unit,
    this.isLive = true,
  });

  @override
  ConsumerState<SensorHistoryDetailChart> createState() =>
      _SensorHistoryDetailChartState();
}

class _SensorHistoryDetailChartState
    extends ConsumerState<SensorHistoryDetailChart> {
  SensorHistoryRange _range = SensorHistoryRange.day;

  String get _rangeLabel => switch (_range) {
    SensorHistoryRange.day => 'Día',
    SensorHistoryRange.week => 'Semana',
    SensorHistoryRange.month => 'Mes',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final historyState = ref.watch(
      sensorHistoryForRangeProvider(widget.sensorId, _range),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText.label(
                'Historial — $_rangeLabel',
                color: colors.textSecondary,
              ),
            ),
            _rangeMenu(colors),
          ],
        ),
        SizedBox(height: tokens.spacing.xSmall),
        SizedBox(
          height: 220,
          width: double.infinity,
          child: historyState.when(
            data: (readings) => _buildChart(readings, colors),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: AppText.caption(
                'No se pudo cargar el historial',
                color: colors.error,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rangeMenu(AppColors colors) {
    return PopupMenuButton<SensorHistoryRange>(
      tooltip: 'Cambiar rango de tiempo',
      icon: Icon(AppIcons.menu, size: 18, color: colors.textSecondary),
      padding: EdgeInsets.zero,
      onSelected: (range) => setState(() => _range = range),
      itemBuilder: (context) => const [
        PopupMenuItem(value: SensorHistoryRange.day, child: Text('Día')),
        PopupMenuItem(value: SensorHistoryRange.week, child: Text('Semana')),
        PopupMenuItem(value: SensorHistoryRange.month, child: Text('Mes')),
      ],
    );
  }

  Widget _buildChart(List<SensorReading> readings, AppColors colors) {
    if (readings.length < 2) {
      return Center(
        child: AppText.caption(
          'Sin datos suficientes',
          color: colors.textSecondary,
        ),
      );
    }

    final lineColor = widget.isLive ? colors.primary : colors.textDisabled;
    final values = [for (final reading in readings) reading.value];
    final minY = values.reduce((a, b) => a < b ? a : b);
    final maxY = values.reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY).abs() < 1e-9 ? 1.0 : (maxY - minY) * 0.15;

    return LineChart(
      duration: widget.isLive
          ? const Duration(milliseconds: 150)
          : Duration.zero,
      LineChartData(
        minY: minY - yPadding,
        maxY: maxY + yPadding,
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: _xAxisInterval(readings.length),
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= readings.length) {
                  return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatAxisDate(readings[index].timestamp),
                    style: TextStyle(color: colors.textSecondary, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: AppText.caption(widget.unit, color: colors.textSecondary),
            axisNameSize: 16,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toStringAsFixed(1),
                  style: TextStyle(color: colors.textSecondary, fontSize: 10),
                ),
              ),
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: colors.divider, strokeWidth: 1),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: colors.divider, width: 1),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => colors.surfaceHigh,
            getTooltipItems: (touchedSpots) => [
              for (final spot in touchedSpots)
                LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} ${widget.unit}\n'
                  '${_formatTooltipDate(readings[spot.x.round()].timestamp)}',
                  TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < readings.length; i++)
                FlSpot(i.toDouble(), readings[i].value),
            ],
            isCurved: true,
            color: lineColor,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  double? _xAxisInterval(int length) {
    if (length <= 1) return null;
    return (length / 5).ceil().clamp(1, length).toDouble();
  }

  String _formatAxisDate(DateTime dateTime) {
    switch (_range) {
      case SensorHistoryRange.day:
        return '${dateTime.hour.toString().padLeft(2, '0')}:00';
      case SensorHistoryRange.week:
      case SensorHistoryRange.month:
        return '${dateTime.day.toString().padLeft(2, '0')}/'
            '${dateTime.month.toString().padLeft(2, '0')}';
    }
  }

  String _formatTooltipDate(DateTime dateTime) {
    if (_range == SensorHistoryRange.day) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:'
          '${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}';
  }
}
