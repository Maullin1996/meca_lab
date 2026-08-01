import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// Stand-in for the real `device_detail` feature, which doesn't exist yet.
/// Reached via a plain [Navigator.push] from the dashboard grid — no
/// go_router route, so it's trivial to swap out later.
class DeviceDetailPlaceholderPage extends StatelessWidget {
  final String deviceName;

  const DeviceDetailPlaceholderPage({super.key, required this.deviceName});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(title: AppText.h6(deviceName, color: colors.textPrimary)),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.medium),
          child: AppText.bodyLg(
            'Detalle de dispositivo próximamente',
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
