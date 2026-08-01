import 'package:atomic_design/atoms/app_themes.dart';
import 'package:atomic_design/atoms/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gate the router behind the initial session check — go_router's own
    // `redirect` decides /login vs /dashboard once this resolves.
    final isResolvingInitialSession = ref
        .watch(authControllerProvider)
        .isLoading;

    return AppThemeProvider(
      // A single `MaterialApp.router` for the whole app lifetime — always,
      // never a second plain `MaterialApp(home: ...)` swapped in during the
      // initial session check. That second MaterialApp used a classic
      // `Navigator` with only "/" registered as a named route; on web, its
      // implicit initial route is still read from the browser's current
      // URL (e.g. /dashboard, left there by go_router after a previous
      // login), which it couldn't find — hence "Could not navigate to
      // initial route" on every reload/restart once the URL had moved past
      // "/". The splash is shown via `builder` instead, which only swaps
      // what's *painted* over the single router's output, never the
      // routing mechanism itself.
      child: MaterialApp.router(
        theme: AppThemes.light,
        darkTheme: AppThemes.dark,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: ref.watch(goRouterProvider),
        builder: (context, child) {
          if (isResolvingInitialSession) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return child!;
        },
      ),
    );
  }
}
