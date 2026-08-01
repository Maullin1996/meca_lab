import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/device_card.dart';
import '../widgets/kpi_card.dart';
import 'dashboard_view_data.dart';

class DashboardWebView extends StatelessWidget {
  final DashboardViewData data;

  const DashboardWebView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: AppText.h6('MecLab IoT', color: colors.primary),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: tokens.spacing.small),
            child: AppButtons(
              key: const Key('logout-button'),
              type: ButtonType.primaryTextButton,
              title: AppText.body('Cerrar sesión', color: colors.textPrimary),
              onPressed: data.onLogout,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(tokens.spacing.medium),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: KpiCard(
                    label: 'Dispositivos',
                    value: '${data.totalDevices}',
                  ),
                ),
                SizedBox(width: tokens.spacing.small),
                Expanded(
                  child: KpiCard(
                    label: 'En alerta',
                    value: '${data.devicesInAlert}',
                  ),
                ),
                SizedBox(width: tokens.spacing.small),
                Expanded(
                  child: KpiCard(
                    label: 'Sensores activos',
                    value: '${data.activeSensors}',
                  ),
                ),
                SizedBox(width: tokens.spacing.small),
                Expanded(
                  child: KpiCard(
                    label: 'Uptime',
                    value: '${data.uptimePercentage.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.spacing.medium),
            Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AppSearchBar(
                  onChanged: data.onSearchChanged,
                  hintText: 'Buscar dispositivo…',
                ),
              ),
            ),
            SizedBox(height: tokens.spacing.medium),
            Expanded(
              child: AppGridView(
                type: data.gridType,
                itemCount: data.devices.length,
                itemBuilder: (context, index) {
                  final device = data.devices[index];
                  return DeviceCard(
                    device: device,
                    onTap: () => data.onDeviceTap(device),
                  );
                },
                childAspectRatio: 1.2,
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
    );
  }
}
