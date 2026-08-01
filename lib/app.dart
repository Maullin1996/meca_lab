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
      child: isResolvingInitialSession
          ? MaterialApp(
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            )
          : MaterialApp.router(
              theme: AppThemes.light,
              darkTheme: AppThemes.dark,
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              routerConfig: ref.watch(goRouterProvider),
            ),
    );
  }
}
