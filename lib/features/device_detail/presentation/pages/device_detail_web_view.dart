import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';
import '../../domain/entities/device_detail.dart';
import '../widgets/device_detail_header.dart';
import '../widgets/recent_alerts_placeholder.dart';
import '../widgets/sensor_detail_card.dart';
import 'device_detail_view_data.dart';

class DeviceDetailWebView extends StatelessWidget {
  final DeviceDetailViewData data;

  const DeviceDetailWebView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);
    final deviceDetail = data.deviceDetail;

    return Scaffold(
      appBar: AppBar(
        title: deviceDetail == null
            ? null
            : AppText.h6(
                deviceDetail.device.name,
                color: colors.textPrimary,
                maxLines: 1,
              ),
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacing.medium),
        child: _buildBody(tokens, deviceDetail),
      ),
    );
  }

  Widget _buildBody(AppTokens tokens, DeviceDetail? deviceDetail) {
    if (data.hasError) {
      return _ErrorState(onRetry: data.onRetry);
    }
    if (deviceDetail == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final isLive = deviceDetail.device.status != DeviceStatus.offline;

    return ListView(
      children: [
        DeviceDetailHeader(deviceDetail: deviceDetail),
        SizedBox(height: tokens.spacing.medium),
        // A fixed-aspect-ratio GridView forces every cell to the same
        // height regardless of content, which left dead space below the
        // old compact chart — this chart is taller and content-driven
        // (axes, range picker), so each card sizes to its own content and
        // wraps to the next line instead.
        Wrap(
          spacing: tokens.spacing.small,
          runSpacing: tokens.spacing.small,
          children: [
            for (final sensor in deviceDetail.sensors)
              SizedBox(
                width: 420,
                child: SensorDetailCard(sensor: sensor, isLive: isLive),
              ),
          ],
        ),
        SizedBox(height: tokens.spacing.medium),
        const RecentAlertsPlaceholder(),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AppStateWidget(
        type: AppStateType.error,
        icon: AppIcons.error,
        title: 'No pudimos cargar el dispositivo',
        buttonChild: const Text('Reintentar'),
        onPressed: onRetry,
      ),
    );
  }
}
