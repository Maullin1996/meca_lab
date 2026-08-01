// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One controller instance per `deviceId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, so each device_detail screen
/// gets its own independent stream/state instead of sharing one.
///
/// [DeviceDetail] (device + full sensor list) already is the plain state
/// widgets need — no extra wrapper class, unlike `DashboardState`, since
/// there's no UI-only field (search, filters) layered on top yet.

@ProviderFor(DeviceDetailController)
final deviceDetailControllerProvider = DeviceDetailControllerFamily._();

/// One controller instance per `deviceId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, so each device_detail screen
/// gets its own independent stream/state instead of sharing one.
///
/// [DeviceDetail] (device + full sensor list) already is the plain state
/// widgets need — no extra wrapper class, unlike `DashboardState`, since
/// there's no UI-only field (search, filters) layered on top yet.
final class DeviceDetailControllerProvider
    extends $StreamNotifierProvider<DeviceDetailController, DeviceDetail> {
  /// One controller instance per `deviceId` — riverpod_generator infers the
  /// family from `build()`'s extra parameter, so each device_detail screen
  /// gets its own independent stream/state instead of sharing one.
  ///
  /// [DeviceDetail] (device + full sensor list) already is the plain state
  /// widgets need — no extra wrapper class, unlike `DashboardState`, since
  /// there's no UI-only field (search, filters) layered on top yet.
  DeviceDetailControllerProvider._({
    required DeviceDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _neverRetry,
         name: r'deviceDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceDetailControllerHash();

  @override
  String toString() {
    return r'deviceDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DeviceDetailController create() => DeviceDetailController();

  @override
  bool operator ==(Object other) {
    return other is DeviceDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceDetailControllerHash() =>
    r'0ec6ce06dc176f5b07fa19ec0f7d194b3d1d2b4e';

/// One controller instance per `deviceId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, so each device_detail screen
/// gets its own independent stream/state instead of sharing one.
///
/// [DeviceDetail] (device + full sensor list) already is the plain state
/// widgets need — no extra wrapper class, unlike `DashboardState`, since
/// there's no UI-only field (search, filters) layered on top yet.

final class DeviceDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          DeviceDetailController,
          AsyncValue<DeviceDetail>,
          DeviceDetail,
          Stream<DeviceDetail>,
          String
        > {
  DeviceDetailControllerFamily._()
    : super(
        retry: _neverRetry,
        name: r'deviceDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One controller instance per `deviceId` — riverpod_generator infers the
  /// family from `build()`'s extra parameter, so each device_detail screen
  /// gets its own independent stream/state instead of sharing one.
  ///
  /// [DeviceDetail] (device + full sensor list) already is the plain state
  /// widgets need — no extra wrapper class, unlike `DashboardState`, since
  /// there's no UI-only field (search, filters) layered on top yet.

  DeviceDetailControllerProvider call(String deviceId) =>
      DeviceDetailControllerProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'deviceDetailControllerProvider';
}

/// One controller instance per `deviceId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, so each device_detail screen
/// gets its own independent stream/state instead of sharing one.
///
/// [DeviceDetail] (device + full sensor list) already is the plain state
/// widgets need — no extra wrapper class, unlike `DashboardState`, since
/// there's no UI-only field (search, filters) layered on top yet.

abstract class _$DeviceDetailController extends $StreamNotifier<DeviceDetail> {
  late final _$args = ref.$arg as String;
  String get deviceId => _$args;

  Stream<DeviceDetail> build(String deviceId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DeviceDetail>, DeviceDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DeviceDetail>, DeviceDetail>,
              AsyncValue<DeviceDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
