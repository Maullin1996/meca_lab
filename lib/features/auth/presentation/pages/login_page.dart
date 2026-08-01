import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/app_breakpoints.dart';
import '../controllers/auth_controller.dart';
import 'login_mobile_view.dart';
import 'login_web_view.dart';

/// Orchestrator: the only file in this screen that reads
/// [authControllerProvider]. Picks [LoginMobileView] or [LoginWebView]
/// based on screen width and hands both the same data/callbacks — no
/// layout or business logic lives here.
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    void handleSubmit(String email, String password) {
      ref
          .read(authControllerProvider.notifier)
          .login(email: email, password: password);
    }

    final isLoading = authState.value?.isSubmitting ?? false;
    final errorMessage = authState.value?.errorMessage;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (AppBreakpoints.isWeb(constraints.maxWidth)) {
          return LoginWebView(
            onSubmit: handleSubmit,
            isLoading: isLoading,
            errorMessage: errorMessage,
          );
        }
        return LoginMobileView(
          onSubmit: handleSubmit,
          isLoading: isLoading,
          errorMessage: errorMessage,
        );
      },
    );
  }
}
