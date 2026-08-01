// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_history_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One controller instance per `sensorId`, deliberately separate from
/// [DeviceDetailController]: each sensor card on the device_detail screen
/// watches its own history independently, instead of one giant state
/// covering every sensor on the device.

@ProviderFor(SensorHistoryController)
final sensorHistoryControllerProvider = SensorHistoryControllerFamily._();

/// One controller instance per `sensorId`, deliberately separate from
/// [DeviceDetailController]: each sensor card on the device_detail screen
/// watches its own history independently, instead of one giant state
/// covering every sensor on the device.
final class SensorHistoryControllerProvider
    extends
        $StreamNotifierProvider<SensorHistoryController, List<SensorReading>> {
  /// One controller instance per `sensorId`, deliberately separate from
  /// [DeviceDetailController]: each sensor card on the device_detail screen
  /// watches its own history independently, instead of one giant state
  /// covering every sensor on the device.
  SensorHistoryControllerProvider._({
    required SensorHistoryControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _neverRetry,
         name: r'sensorHistoryControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sensorHistoryControllerHash();

  @override
  String toString() {
    return r'sensorHistoryControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SensorHistoryController create() => SensorHistoryController();

  @override
  bool operator ==(Object other) {
    return other is SensorHistoryControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sensorHistoryControllerHash() =>
    r'fe587ce9cb1c2672014a7ec1b16263b3caf8c541';

/// One controller instance per `sensorId`, deliberately separate from
/// [DeviceDetailController]: each sensor card on the device_detail screen
/// watches its own history independently, instead of one giant state
/// covering every sensor on the device.

final class SensorHistoryControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          SensorHistoryController,
          AsyncValue<List<SensorReading>>,
          List<SensorReading>,
          Stream<List<SensorReading>>,
          String
        > {
  SensorHistoryControllerFamily._()
    : super(
        retry: _neverRetry,
        name: r'sensorHistoryControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One controller instance per `sensorId`, deliberately separate from
  /// [DeviceDetailController]: each sensor card on the device_detail screen
  /// watches its own history independently, instead of one giant state
  /// covering every sensor on the device.

  SensorHistoryControllerProvider call(String sensorId) =>
      SensorHistoryControllerProvider._(argument: sensorId, from: this);

  @override
  String toString() => r'sensorHistoryControllerProvider';
}

/// One controller instance per `sensorId`, deliberately separate from
/// [DeviceDetailController]: each sensor card on the device_detail screen
/// watches its own history independently, instead of one giant state
/// covering every sensor on the device.

abstract class _$SensorHistoryController
    extends $StreamNotifier<List<SensorReading>> {
  late final _$args = ref.$arg as String;
  String get sensorId => _$args;

  Stream<List<SensorReading>> build(String sensorId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<SensorReading>>, List<SensorReading>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SensorReading>>, List<SensorReading>>,
              AsyncValue<List<SensorReading>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
