import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../controllers/device_detail_controller.dart';
import 'device_detail_mobile_view.dart';
import 'device_detail_view_data.dart';
import 'device_detail_web_view.dart';

/// Orchestrator: the only file in this screen that reads
/// [deviceDetailControllerProvider] for the device + full sensor list.
/// Picks [DeviceDetailMobileView] or [DeviceDetailWebView] based on screen
/// width and hands both the same resolved data/callbacks — no layout or
/// business logic lives here.
///
/// Per-sensor history is watched separately by each sensor card
/// (`sensor_sparkline.dart`), not here.
class DeviceDetailPage extends ConsumerWidget {
  final String deviceId;

  const DeviceDetailPage({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(deviceDetailControllerProvider(deviceId));

    void handleRetry() {
      ref.invalidate(deviceDetailControllerProvider(deviceId));
    }

    final viewData = DeviceDetailViewData(
      deviceDetail: detailState.value,
      hasError: detailState.hasError,
      onRetry: handleRetry,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isWeb(constraints.maxWidth)) {
          return DeviceDetailWebView(data: viewData);
        }
        return DeviceDetailMobileView(data: viewData);
      },
    );
  }
}
