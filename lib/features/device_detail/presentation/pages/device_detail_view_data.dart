import 'package:flutter/widgets.dart';

import '../../domain/entities/device_detail.dart';

/// Everything [DeviceDetailMobileView]/[DeviceDetailWebView] need, already
/// resolved by the orchestrator (`device_detail_page.dart`) — the views
/// never touch Riverpod or fpdart for the device/sensor list.
///
/// Per-sensor history is deliberately **not** here: each sensor card watches
/// its own `sensorHistoryControllerProvider` directly (see
/// `sensor_history_chart.dart`), so it isn't lifted into this bag.
class DeviceDetailViewData {
  final DeviceDetail? deviceDetail;
  final bool hasError;
  final VoidCallback onRetry;

  const DeviceDetailViewData({
    required this.deviceDetail,
    required this.hasError,
    required this.onRetry,
  });
}
