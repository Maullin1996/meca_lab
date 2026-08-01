// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_history_range_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One-shot read per `(sensorId, range)` — riverpod_generator infers the
/// family from the extra `build()` parameters, same as the other family
/// providers in this feature. A plain function provider (not a
/// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
/// `Future`, not a live stream — switching the range picker just reads a
/// different cached value instead of resubscribing to anything.

@ProviderFor(sensorHistoryForRange)
final sensorHistoryForRangeProvider = SensorHistoryForRangeFamily._();

/// One-shot read per `(sensorId, range)` — riverpod_generator infers the
/// family from the extra `build()` parameters, same as the other family
/// providers in this feature. A plain function provider (not a
/// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
/// `Future`, not a live stream — switching the range picker just reads a
/// different cached value instead of resubscribing to anything.

final class SensorHistoryForRangeProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SensorReading>>,
          List<SensorReading>,
          FutureOr<List<SensorReading>>
        >
    with
        $FutureModifier<List<SensorReading>>,
        $FutureProvider<List<SensorReading>> {
  /// One-shot read per `(sensorId, range)` — riverpod_generator infers the
  /// family from the extra `build()` parameters, same as the other family
  /// providers in this feature. A plain function provider (not a
  /// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
  /// `Future`, not a live stream — switching the range picker just reads a
  /// different cached value instead of resubscribing to anything.
  SensorHistoryForRangeProvider._({
    required SensorHistoryForRangeFamily super.from,
    required (String, SensorHistoryRange) super.argument,
  }) : super(
         retry: null,
         name: r'sensorHistoryForRangeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sensorHistoryForRangeHash();

  @override
  String toString() {
    return r'sensorHistoryForRangeProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<SensorReading>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SensorReading>> create(Ref ref) {
    final argument = this.argument as (String, SensorHistoryRange);
    return sensorHistoryForRange(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is SensorHistoryForRangeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sensorHistoryForRangeHash() =>
    r'45c66606b6753a60ce8d333389288165a2ee94b8';

/// One-shot read per `(sensorId, range)` — riverpod_generator infers the
/// family from the extra `build()` parameters, same as the other family
/// providers in this feature. A plain function provider (not a
/// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
/// `Future`, not a live stream — switching the range picker just reads a
/// different cached value instead of resubscribing to anything.

final class SensorHistoryForRangeFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<SensorReading>>,
          (String, SensorHistoryRange)
        > {
  SensorHistoryForRangeFamily._()
    : super(
        retry: null,
        name: r'sensorHistoryForRangeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One-shot read per `(sensorId, range)` — riverpod_generator infers the
  /// family from the extra `build()` parameters, same as the other family
  /// providers in this feature. A plain function provider (not a
  /// `StreamNotifier`) because [GetSensorHistoryForRangeUseCase] is a single
  /// `Future`, not a live stream — switching the range picker just reads a
  /// different cached value instead of resubscribing to anything.

  SensorHistoryForRangeProvider call(
    String sensorId,
    SensorHistoryRange range,
  ) => SensorHistoryForRangeProvider._(argument: (sensorId, range), from: this);

  @override
  String toString() => r'sensorHistoryForRangeProvider';
}
