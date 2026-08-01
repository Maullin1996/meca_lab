import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

import '../widgets/device_card.dart';
import '../widgets/kpi_card.dart';
import '../widgets/responsive_device_grid.dart';
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
                // ResponsiveDeviceGrid sizes cells purely from this ratio
                // (no content-based autosizing) — but unlike AppGridView it
                // keeps adding columns past 840px (see its column-count
                // breakpoints), so card width stays roughly bounded instead
                // of stretching 4 cards across arbitrarily wide screens.
                // DeviceCard now graphs exactly one sensor (see its doc
                // comment), so content height is light and roughly constant
                // — 1.6 fits that comfortably across the column range, with
                // a scroll safety net in the card for the rare narrow edge.
                childAspectRatio: 1.6,
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
