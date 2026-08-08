import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../data/providers/auth_repository_provider.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

part 'auth_controller.g.dart';

enum AuthStatus { unauthenticated, authenticated }

/// Plain state exposed to `presentation` widgets — no `Either`/`Failure`
/// leaks past this point.
///
/// [isSubmitting] tracks a login/logout attempt in flight. The top-level
/// `AsyncValue.loading()` on [AuthController] is reserved for the one-time
/// initial session check (the router's app.dart gate watches that), so
/// login/logout never touch it — otherwise every submit would look like
/// "session still resolving" to anything gating on it.
class AuthSessionState {
  final AuthStatus status;
  final User? user;
  final String? errorMessage;
  final bool isSubmitting;

  const AuthSessionState._({
    required this.status,
    this.user,
    this.errorMessage,
    this.isSubmitting = false,
  });

  const AuthSessionState.unauthenticated({
    String? errorMessage,
    bool isSubmitting = false,
  }) : this._(
         status: AuthStatus.unauthenticated,
         errorMessage: errorMessage,
         isSubmitting: isSubmitting,
       );

  const AuthSessionState.authenticated(User user, {bool isSubmitting = false})
    : this._(
        status: AuthStatus.authenticated,
        user: user,
        isSubmitting: isSubmitting,
      );

  bool get isAuthenticated => status == AuthStatus.authenticated;

  AuthSessionState copyWithSubmitting(bool isSubmitting) => AuthSessionState._(
    status: status,
    user: user,
    errorMessage: errorMessage,
    isSubmitting: isSubmitting,
  );
}

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each use case result into [AuthSessionState] for widgets to
/// consume directly.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthSessionState> build() async {
    final repository = ref.watch(authRepositoryProvider);
    final result = await GetCurrentSessionUseCase(repository)();

    return result.fold(
      (failure) => const AuthSessionState.unauthenticated(),
      (user) => AuthSessionState.authenticated(user),
    );
  }

  Future<void> login({required String email, required String password}) async {
    final repository = ref.read(authRepositoryProvider);
    final current = state.value ?? const AuthSessionState.unauthenticated();
    state = AsyncValue.data(current.copyWithSubmitting(true));

    final result = await LoginUseCase(repository)(
      email: email,
      password: password,
    );

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthSessionState.unauthenticated(
          errorMessage: _messageFor(failure),
        ),
        (user) => AuthSessionState.authenticated(user),
      ),
    );
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    final current = state.value ?? const AuthSessionState.unauthenticated();
    state = AsyncValue.data(current.copyWithSubmitting(true));

    final result = await LogoutUseCase(repository)();

    state = AsyncValue.data(
      result.fold(
        (failure) => AuthSessionState.unauthenticated(
          errorMessage: _messageFor(failure),
        ),
        (_) => const AuthSessionState.unauthenticated(),
      ),
    );
  }

  String _messageFor(Failure failure) {
    return switch (failure) {
      InvalidCredentialsFailure() => 'Email o contraseña incorrectos.',
      NoSessionFailure() => 'No hay una sesión activa.',
      NotFoundFailure() => 'No pudimos encontrar el elemento solicitado.',
      UnauthorizedFailure() => 'No tienes permisos para realizar esta acción.',
      ValidationFailure(:final message) => message,

      UnexpectedFailure(:final message) =>
        'Ocurrió un error inesperado: $message',
    };
  }
}
