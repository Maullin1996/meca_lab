// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_history_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sensorHistoryRepositoryImpl)
final sensorHistoryRepositoryImplProvider =
    SensorHistoryRepositoryImplProvider._();

final class SensorHistoryRepositoryImplProvider
    extends
        $FunctionalProvider<
          SensorHistoryRepository,
          SensorHistoryRepository,
          SensorHistoryRepository
        >
    with $Provider<SensorHistoryRepository> {
  SensorHistoryRepositoryImplProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sensorHistoryRepositoryImplProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sensorHistoryRepositoryImplHash();

  @$internal
  @override
  $ProviderElement<SensorHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SensorHistoryRepository create(Ref ref) {
    return sensorHistoryRepositoryImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SensorHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SensorHistoryRepository>(value),
    );
  }
}

String _$sensorHistoryRepositoryImplHash() =>
    r'67a7804fe3769b19f1fb50bfdb4e6202e0ea2767';
