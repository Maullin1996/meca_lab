// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place in `presentation` that touches `Either`/`fpdart`.

@ProviderFor(AlertsController)
final alertsControllerProvider = AlertsControllerProvider._();

/// The only place in `presentation` that touches `Either`/`fpdart`.
final class AlertsControllerProvider
    extends $AsyncNotifierProvider<AlertsController, AlertsState> {
  /// The only place in `presentation` that touches `Either`/`fpdart`.
  AlertsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'alertsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertsControllerHash();

  @$internal
  @override
  AlertsController create() => AlertsController();
}

String _$alertsControllerHash() => r'ccac936cb4c74933fd1e5b54b536f52cf2144951';

/// The only place in `presentation` that touches `Either`/`fpdart`.

abstract class _$AlertsController extends $AsyncNotifier<AlertsState> {
  FutureOr<AlertsState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AlertsState>, AlertsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AlertsState>, AlertsState>,
              AsyncValue<AlertsState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
