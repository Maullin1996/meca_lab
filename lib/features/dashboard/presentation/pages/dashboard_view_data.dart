import 'package:atomic_design/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../../../shared/domain/entities/device.dart';

/// Everything [DashboardMobileView]/[DashboardWebView] need, already
/// resolved by the orchestrator (`dashboard_page.dart`) — the views never
/// touch Riverpod or fpdart, only this plain bag of data/callbacks.
class DashboardViewData {
  final List<Device> devices;
  final GridViewType gridType;
  final int totalDevices;
  final int devicesInAlert;
  final int activeSensors;
  final double uptimePercentage;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Device> onDeviceTap;
  final VoidCallback onRetry;
  final VoidCallback onLogout;

  const DashboardViewData({
    required this.devices,
    required this.gridType,
    required this.totalDevices,
    required this.devicesInAlert,
    required this.activeSensors,
    required this.uptimePercentage,
    required this.onSearchChanged,
    required this.onDeviceTap,
    required this.onRetry,
    required this.onLogout,
  });
}
