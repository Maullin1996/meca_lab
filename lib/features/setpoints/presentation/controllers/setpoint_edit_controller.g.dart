// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setpoint_edit_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One controller instance per `sensorId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, same as `DeviceDetailController`
/// and `SensorHistoryRangeController`.

@ProviderFor(SetpointEditController)
final setpointEditControllerProvider = SetpointEditControllerFamily._();

/// One controller instance per `sensorId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, same as `DeviceDetailController`
/// and `SensorHistoryRangeController`.
final class SetpointEditControllerProvider
    extends $AsyncNotifierProvider<SetpointEditController, SetpointEditState> {
  /// One controller instance per `sensorId` — riverpod_generator infers the
  /// family from `build()`'s extra parameter, same as `DeviceDetailController`
  /// and `SensorHistoryRangeController`.
  SetpointEditControllerProvider._({
    required SetpointEditControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'setpointEditControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$setpointEditControllerHash();

  @override
  String toString() {
    return r'setpointEditControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SetpointEditController create() => SetpointEditController();

  @override
  bool operator ==(Object other) {
    return other is SetpointEditControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$setpointEditControllerHash() =>
    r'a00f7308e801559d26a193622d3e80ff6ceb6202';

/// One controller instance per `sensorId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, same as `DeviceDetailController`
/// and `SensorHistoryRangeController`.

final class SetpointEditControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SetpointEditController,
          AsyncValue<SetpointEditState>,
          SetpointEditState,
          FutureOr<SetpointEditState>,
          String
        > {
  SetpointEditControllerFamily._()
    : super(
        retry: null,
        name: r'setpointEditControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One controller instance per `sensorId` — riverpod_generator infers the
  /// family from `build()`'s extra parameter, same as `DeviceDetailController`
  /// and `SensorHistoryRangeController`.

  SetpointEditControllerProvider call(String sensorId) =>
      SetpointEditControllerProvider._(argument: sensorId, from: this);

  @override
  String toString() => r'setpointEditControllerProvider';
}

/// One controller instance per `sensorId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, same as `DeviceDetailController`
/// and `SensorHistoryRangeController`.

abstract class _$SetpointEditController
    extends $AsyncNotifier<SetpointEditState> {
  late final _$args = ref.$arg as String;
  String get sensorId => _$args;

  FutureOr<SetpointEditState> build(String sensorId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SetpointEditState>, SetpointEditState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SetpointEditState>, SetpointEditState>,
              AsyncValue<SetpointEditState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
