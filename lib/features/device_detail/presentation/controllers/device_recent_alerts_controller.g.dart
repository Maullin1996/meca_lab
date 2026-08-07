// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_recent_alerts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only per `deviceId` — riverpod_generator infers the family from the
/// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
/// function provider, not a `Notifier`, because this screen never mutates
/// alerts (no acknowledge here) — it only reads the top 5 recent
/// warning/critical alerts for its own device.

@ProviderFor(deviceRecentAlerts)
final deviceRecentAlertsProvider = DeviceRecentAlertsFamily._();

/// Read-only per `deviceId` — riverpod_generator infers the family from the
/// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
/// function provider, not a `Notifier`, because this screen never mutates
/// alerts (no acknowledge here) — it only reads the top 5 recent
/// warning/critical alerts for its own device.

final class DeviceRecentAlertsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Alert>>,
          List<Alert>,
          FutureOr<List<Alert>>
        >
    with $FutureModifier<List<Alert>>, $FutureProvider<List<Alert>> {
  /// Read-only per `deviceId` — riverpod_generator infers the family from the
  /// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
  /// function provider, not a `Notifier`, because this screen never mutates
  /// alerts (no acknowledge here) — it only reads the top 5 recent
  /// warning/critical alerts for its own device.
  DeviceRecentAlertsProvider._({
    required DeviceRecentAlertsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'deviceRecentAlertsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$deviceRecentAlertsHash();

  @override
  String toString() {
    return r'deviceRecentAlertsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Alert>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Alert>> create(Ref ref) {
    final argument = this.argument as String;
    return deviceRecentAlerts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DeviceRecentAlertsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$deviceRecentAlertsHash() =>
    r'6f2dff4fb7bec58b7eb59398bf50f310848502c4';

/// Read-only per `deviceId` — riverpod_generator infers the family from the
/// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
/// function provider, not a `Notifier`, because this screen never mutates
/// alerts (no acknowledge here) — it only reads the top 5 recent
/// warning/critical alerts for its own device.

final class DeviceRecentAlertsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Alert>>, String> {
  DeviceRecentAlertsFamily._()
    : super(
        retry: null,
        name: r'deviceRecentAlertsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Read-only per `deviceId` — riverpod_generator infers the family from the
  /// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
  /// function provider, not a `Notifier`, because this screen never mutates
  /// alerts (no acknowledge here) — it only reads the top 5 recent
  /// warning/critical alerts for its own device.

  DeviceRecentAlertsProvider call(String deviceId) =>
      DeviceRecentAlertsProvider._(argument: deviceId, from: this);

  @override
  String toString() => r'deviceRecentAlertsProvider';
}
