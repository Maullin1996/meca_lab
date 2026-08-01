import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

part 'app_router.g.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const dashboard = '/dashboard';
}

@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  final refreshNotifier = _AuthRefreshNotifier(ref);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final isAuthenticated =
          ref.read(authControllerProvider).value?.isAuthenticated ?? false;
      final isLoggingIn = state.matchedLocation == AppRoutes.login;

      if (!isAuthenticated) return isLoggingIn ? null : AppRoutes.login;
      if (isLoggingIn) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
    ],
  );
}

/// Notifies go_router to re-evaluate `redirect` whenever the auth session
/// state changes (login, logout, or the initial session check resolving).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}
