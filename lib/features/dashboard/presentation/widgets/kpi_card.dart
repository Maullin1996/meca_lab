import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// Feature-scoped for now — becomes a `lib/shared/widgets/` candidate only
/// if another feature ends up needing the same KPI card shape.
class KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const KpiCard({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return AppCard(
      padding: EdgeInsets.all(tokens.spacing.small),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText.h3(value, color: colors.primary),
          SizedBox(height: tokens.spacing.xSmall),
          AppText.label(label, color: colors.textSecondary),
        ],
      ),
    );
  }
}
