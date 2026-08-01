import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// Stand-in for "alertas recientes del dispositivo" — the `alerts` feature
/// doesn't exist yet. Purely visual: no route, no data, no logic of its
/// own. Replace with the real section once `alerts` ships.
class RecentAlertsPlaceholder extends StatelessWidget {
  const RecentAlertsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      type: AppStateType.empty,
      icon: AppIcons.notification,
      title: 'Alertas — próximamente',
      buttonChild: const Text('Entendido'),
      onPressed: () {},
    );
  }
}
