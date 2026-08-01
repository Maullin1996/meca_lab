// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each [WatchDevicesUseCase] emission into [DashboardState] for
/// widgets to consume directly. `build()` returns a `Stream` (not a
/// `Future`) because the use case itself is a live stream, which
/// riverpod_generator maps to a `StreamNotifier` — widgets still just see
/// `AsyncValue<DashboardState>` either way.

@ProviderFor(DashboardController)
final dashboardControllerProvider = DashboardControllerProvider._();

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each [WatchDevicesUseCase] emission into [DashboardState] for
/// widgets to consume directly. `build()` returns a `Stream` (not a
/// `Future`) because the use case itself is a live stream, which
/// riverpod_generator maps to a `StreamNotifier` — widgets still just see
/// `AsyncValue<DashboardState>` either way.
final class DashboardControllerProvider
    extends $StreamNotifierProvider<DashboardController, DashboardState> {
  /// The only place in `presentation` that touches `Either`/`fpdart` — it
  /// `.fold()`s each [WatchDevicesUseCase] emission into [DashboardState] for
  /// widgets to consume directly. `build()` returns a `Stream` (not a
  /// `Future`) because the use case itself is a live stream, which
  /// riverpod_generator maps to a `StreamNotifier` — widgets still just see
  /// `AsyncValue<DashboardState>` either way.
  DashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: _neverRetry,
        name: r'dashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardControllerHash();

  @$internal
  @override
  DashboardController create() => DashboardController();
}

String _$dashboardControllerHash() =>
    r'25a4eac5d5cc1f25a14b984fdc7e9933264f23c9';

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each [WatchDevicesUseCase] emission into [DashboardState] for
/// widgets to consume directly. `build()` returns a `Stream` (not a
/// `Future`) because the use case itself is a live stream, which
/// riverpod_generator maps to a `StreamNotifier` — widgets still just see
/// `AsyncValue<DashboardState>` either way.

abstract class _$DashboardController extends $StreamNotifier<DashboardState> {
  Stream<DashboardState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DashboardState>, DashboardState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DashboardState>, DashboardState>,
              AsyncValue<DashboardState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
