import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/device_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/responsive_device_grid.dart';
import 'dashboard_view_data.dart';

class DashboardMobileView extends StatelessWidget {
  final DashboardViewData data;

  const DashboardMobileView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText.h6('MecLab IoT', color: colors.primary),
        actions: [
          AppButtons(
            key: const Key('logout-button'),
            type: ButtonType.primaryIconButton,
            icon: Icons.logout,
            onPressed: data.onLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.spacing.small),
          child: Column(
            children: [
              SizedBox(
                height: 96,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    KpiCard(
                      label: 'Dispositivos',
                      value: '${data.totalDevices}',
                    ),
                    SizedBox(width: tokens.spacing.small),
                    KpiCard(
                      label: 'En alerta',
                      value: '${data.devicesInAlert}',
                    ),
                    SizedBox(width: tokens.spacing.small),
                    KpiCard(
                      label: 'Sensores activos',
                      value: '${data.activeSensors}',
                    ),
                    SizedBox(width: tokens.spacing.small),
                    KpiCard(
                      label: 'Uptime',
                      value: '${data.uptimePercentage.toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
              SizedBox(height: tokens.spacing.small),
              AppSearchBar(
                onChanged: data.onSearchChanged,
                hintText: 'Buscar dispositivo…',
              ),
              SizedBox(height: tokens.spacing.small),
              Expanded(
                child: ResponsiveDeviceGrid(
                  type: data.gridType,
                  itemCount: data.devices.length,
                  itemBuilder: (context, index) {
                    final device = data.devices[index];
                    return DeviceCard(
                      device: device,
                      onTap: () => data.onDeviceTap(device),
                    );
                  },
                  childAspectRatio: 0.95,
                  emptyWidget: AppStateWidget(
                    type: AppStateType.empty,
                    icon: AppIcons.information,
                    title: 'Ningún dispositivo coincide con tu búsqueda',
                    buttonChild: const Text('Limpiar búsqueda'),
                    onPressed: () => data.onSearchChanged(''),
                  ),
                  errorWidget: AppStateWidget(
                    type: AppStateType.error,
                    icon: AppIcons.error,
                    title: 'No pudimos cargar los dispositivos',
                    buttonChild: const Text('Reintentar'),
                    onPressed: data.onRetry,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
