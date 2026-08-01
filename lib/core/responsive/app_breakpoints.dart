/// `atomic_design` resolves responsive *token values* (spacing, radius,
/// typography) per breakpoint, but doesn't expose a semantic "which
/// breakpoint is this" helper. This is the one place that defines the
/// mobile/web layout cutoff — reuse it instead of hardcoding a threshold
/// per screen.
abstract class AppBreakpoints {
  /// Below this width, screens use their mobile layout; at or above it,
  /// the web layout (different `Scaffold`/`AppBar` composition, not just a
  /// grid column count — see `dashboard_mobile_view.dart`/`_web_view.dart`).
  static const double web = 600;

  static bool isWeb(double width) => width >= web;
}
