// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each use case result into [AuthSessionState] for widgets to
/// consume directly.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each use case result into [AuthSessionState] for widgets to
/// consume directly.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, AuthSessionState> {
  /// The only place in `presentation` that touches `Either`/`fpdart` — it
  /// `.fold()`s each use case result into [AuthSessionState] for widgets to
  /// consume directly.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'88dadc58b0c245292d839a12af531c8cef58ce9a';

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each use case result into [AuthSessionState] for widgets to
/// consume directly.

abstract class _$AuthController extends $AsyncNotifier<AuthSessionState> {
  FutureOr<AuthSessionState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AuthSessionState>, AuthSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AuthSessionState>, AuthSessionState>,
              AsyncValue<AuthSessionState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
