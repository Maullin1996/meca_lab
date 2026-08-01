import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../shared/domain/entities/device.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import 'dashboard_mobile_view.dart';
import 'dashboard_view_data.dart';
import 'dashboard_web_view.dart';
import 'device_detail_placeholder_page.dart';

/// Orchestrator: the only file in this screen that reads
/// [dashboardControllerProvider]. Picks [DashboardMobileView] or
/// [DashboardWebView] based on screen width and hands both the same
/// resolved data/callbacks — no layout or business logic lives here.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardControllerProvider);
    final state = dashboardState.value;

    final gridType = dashboardState.when(
      data: (value) =>
          value.filteredDevices.isEmpty ? GridViewType.empty : GridViewType.list,
      loading: () => GridViewType.loading,
      error: (error, stackTrace) => GridViewType.error,
    );

    void handleSearch(String query) {
      ref.read(dashboardControllerProvider.notifier).search(query);
    }

    void handleRetry() {
      ref.invalidate(dashboardControllerProvider);
    }

    void handleLogout() {
      ref.read(authControllerProvider.notifier).logout();
    }

    void handleDeviceTap(Device device) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              DeviceDetailPlaceholderPage(deviceName: device.name),
        ),
      );
    }

    final viewData = DashboardViewData(
      devices: state?.filteredDevices ?? const [],
      gridType: gridType,
      totalDevices: state?.totalDevices ?? 0,
      devicesInAlert: state?.devicesInAlert ?? 0,
      activeSensors: state?.activeSensors ?? 0,
      uptimePercentage: state?.uptimePercentage ?? 0,
      onSearchChanged: handleSearch,
      onDeviceTap: handleDeviceTap,
      onRetry: handleRetry,
      onLogout: handleLogout,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isWeb(constraints.maxWidth)) {
          return DashboardWebView(data: viewData);
        }
        return DashboardMobileView(data: viewData);
      },
    );
  }
}
