// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceRepositoryImpl)
final deviceRepositoryImplProvider = DeviceRepositoryImplProvider._();

final class DeviceRepositoryImplProvider
    extends
        $FunctionalProvider<
          DeviceRepository,
          DeviceRepository,
          DeviceRepository
        >
    with $Provider<DeviceRepository> {
  DeviceRepositoryImplProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceRepositoryImplProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceRepositoryImplHash();

  @$internal
  @override
  $ProviderElement<DeviceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceRepository create(Ref ref) {
    return deviceRepositoryImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceRepository>(value),
    );
  }
}

String _$deviceRepositoryImplHash() =>
    r'835384cc2266ea4a62b11230e0a4a0001147366c';
