import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/domain/entities/device.dart';
import '../../domain/entities/device_detail.dart';
import '../widgets/device_detail_header.dart';
import '../widgets/device_recent_alerts_section.dart';
import '../widgets/sensor_detail_card.dart';
import 'device_detail_view_data.dart';

class DeviceDetailMobileView extends StatelessWidget {
  final DeviceDetailViewData data;

  const DeviceDetailMobileView({super.key, required this.data});

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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.small),
          child: _buildBody(tokens, deviceDetail),
        ),
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
    return ListView(
      children: [
        DeviceDetailHeader(deviceDetail: deviceDetail),
        SizedBox(height: tokens.spacing.medium),
        for (final sensor in deviceDetail.sensors)
          Padding(
            padding: EdgeInsets.only(bottom: tokens.spacing.small),
            child: SensorDetailCard(
              sensor: sensor,
              isLive: deviceDetail.device.status != DeviceStatus.offline,
            ),
          ),
        DeviceRecentAlertsSection(deviceId: deviceDetail.device.id),
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
