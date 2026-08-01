import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';
import '../../../../shared/domain/entities/sensor.dart';
import '../../../../shared/widgets/device_status_badge.dart';
import '../../../../shared/widgets/sensor_history_chart.dart';

/// Feature-scoped for now — becomes a `lib/shared/widgets/` candidate only
/// once `device_detail` needs the same card (second-consumer rule).
///
/// Stateful only for [_chartedSensorId]: which of [Device.keySensors] is
/// currently graphed. Stacking one chart per sensor doesn't fit
/// `ResponsiveDeviceGrid`'s fixed-aspect-ratio cells across breakpoints (a
/// card with 2 sensors needs roughly double the height of one with 1), so
/// the card always graphs exactly one sensor — every sensor's current
/// reading is still listed as plain text, which costs a single line each —
/// and a menu switches which one is charted when there's more than one.
class DeviceCard extends StatefulWidget {
  final Device device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  State<DeviceCard> createState() => _DeviceCardState();
}

class _DeviceCardState extends State<DeviceCard> {
  late String _chartedSensorId = widget.device.keySensors.isEmpty
      ? ''
      : widget.device.keySensors.first.id;

  @override
  void didUpdateWidget(DeviceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The mock stream can replace a device's keySensors wholesale (e.g. on
    // reconnect) — fall back to the first sensor if the charted one no
    // longer exists, instead of pointing at a stale id.
    final stillExists = widget.device.keySensors.any(
      (sensor) => sensor.id == _chartedSensorId,
    );
    if (!stillExists) {
      _chartedSensorId = widget.device.keySensors.isEmpty
          ? ''
          : widget.device.keySensors.first.id;
    }
  }

  String get _typeLabel => switch (widget.device.type) {
    DeviceType.compresor => 'Compresor',
    DeviceType.motor => 'Motor',
    DeviceType.bomba => 'Bomba',
    DeviceType.banda => 'Banda transportadora',
  };

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final device = widget.device;
    final sensors = device.keySensors;

    return InkWell(
      borderRadius: BorderRadius.circular(tokens.radius.medium),
      onTap: widget.onTap,
      child: AppCard(
        padding: EdgeInsets.all(tokens.spacing.small),
        // Content height is now light and mostly constant (one chart, one
        // text line per sensor), but `AppGridView`'s fixed-aspect-ratio
        // cells can still come out shorter than that at some breakpoints —
        // this scroll is a safety net for that edge, not the primary way
        // users are meant to see a second sensor (that's the menu above).
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.h6(device.name, color: colors.textPrimary, maxLines: 1),
              SizedBox(height: tokens.spacing.xSmall),
              DeviceStatusBadge(status: device.status),
              SizedBox(height: tokens.spacing.xSmall),
              AppText.label(_typeLabel, color: colors.textSecondary),
              for (final sensor in sensors)
                Padding(
                  padding: EdgeInsets.only(top: tokens.spacing.xSmall),
                  child: AppText.caption(
                    '${sensor.name}: ${sensor.currentValue.toStringAsFixed(1)} ${sensor.unit}',
                    color: colors.textSecondary,
                  ),
                ),
              if (sensors.isNotEmpty) ...[
                SizedBox(height: tokens.spacing.xSmall),
                Row(
                  children: [
                    Expanded(
                      child: AppText.caption(
                        'Historial: ${_chartedSensor(sensors).name}',
                        color: colors.textDisabled,
                      ),
                    ),
                    if (sensors.length > 1) _sensorMenu(sensors, colors),
                  ],
                ),
                SensorHistoryChart(
                  sensorId: _chartedSensor(sensors).id,
                  variant: ChartVariant.compact,
                  isLive: device.status != DeviceStatus.offline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Sensor _chartedSensor(List<Sensor> sensors) =>
      sensors.firstWhere((sensor) => sensor.id == _chartedSensorId);

  Widget _sensorMenu(List<Sensor> sensors, AppColors colors) {
    return PopupMenuButton<String>(
      tooltip: 'Elegir sensor a graficar',
      icon: Icon(AppIcons.menu, size: 16, color: colors.textSecondary),
      padding: EdgeInsets.zero,
      onSelected: (sensorId) => setState(() => _chartedSensorId = sensorId),
      itemBuilder: (context) => [
        for (final sensor in sensors)
          PopupMenuItem(value: sensor.id, child: Text(sensor.name)),
      ],
    );
  }
}
