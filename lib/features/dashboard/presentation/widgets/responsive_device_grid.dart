import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// `atomic_design`'s `AppGridView` hardcodes its own column breakpoints
/// (1/360, 2/600, 3/840, 4/840+) with no way to override them, and they
/// don't fit this dashboard: `DeviceCard` got noticeably lighter once it
/// settled on graphing one sensor at a time (see `device_card.dart`), so a
/// fixed `childAspectRatio` tuned for the 4-column range left either dead
/// space on wide screens or cramped/scrolling cards on narrower ones. Per
/// the skill's guidance for organisms that don't fit ("no lo fuerces —
/// compón la pantalla directamente"), this composes the grid directly with
/// `GridView.builder` and its own breakpoints, reusing `AppCard`/
/// `AppStateWidget` for the loading/empty/error states instead of
/// reinventing those.
///
/// Column count scales roughly every ~450-480px of width instead of
/// plateauing at 4: <450 → 1, <890 → 2, <1440 → 3, <1920 → 4, then +1 every
/// further 480px — so very wide monitors keep gaining columns instead of
/// stretching 4 cards thin.
class ResponsiveDeviceGrid extends StatelessWidget {
  final GridViewType type;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Widget emptyWidget;
  final Widget errorWidget;
  final double childAspectRatio;

  const ResponsiveDeviceGrid({
    super.key,
    required this.type,
    required this.itemCount,
    required this.itemBuilder,
    required this.emptyWidget,
    required this.errorWidget,
    this.childAspectRatio = 1.0,
  });

  static int columnCountForWidth(double width) {
    if (width < 450) return 1;
    if (width < 890) return 2;
    if (width < 1440) return 3;
    return 4 + ((width - 1440) / 480).floor();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.standard,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (type) {
        GridViewType.list => KeyedSubtree(
          key: const ValueKey('list'),
          child: _grid(context, itemCount, itemBuilder),
        ),
        GridViewType.loading => KeyedSubtree(
          key: const ValueKey('loading'),
          child: _grid(
            context,
            8,
            (context, index) =>
                AppCard(isLoading: true, child: const SizedBox()),
          ),
        ),
        GridViewType.empty => KeyedSubtree(
          key: const ValueKey('empty'),
          child: _CenteredState(child: emptyWidget),
        ),
        GridViewType.error => KeyedSubtree(
          key: const ValueKey('error'),
          child: _CenteredState(child: errorWidget),
        ),
      },
    );
  }

  Widget _grid(BuildContext context, int count, IndexedWidgetBuilder builder) {
    final tokens = AppTokens.of(context);
    final columnCount = columnCountForWidth(MediaQuery.sizeOf(context).width);

    return GridView.builder(
      padding: EdgeInsets.all(tokens.spacing.small),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        mainAxisSpacing: tokens.spacing.xSmall,
        crossAxisSpacing: tokens.spacing.xSmall,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: count,
      itemBuilder: builder,
    );
  }
}

class _CenteredState extends StatelessWidget {
  final Widget child;

  const _CenteredState({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth < 600 ? screenWidth * 0.80 : 420.0;
    final tokens = AppTokens.of(context);

    return Center(
      child: Container(
        padding: EdgeInsets.all(tokens.spacing.small),
        constraints: BoxConstraints(maxWidth: maxWidth),
        decoration: BoxDecoration(
          color: AppColors.of(context).surfaceHigh,
          borderRadius: BorderRadius.circular(tokens.radius.medium),
        ),
        child: child,
      ),
    );
  }
}
