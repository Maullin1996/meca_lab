// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_device_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mockDeviceDataSource)
final mockDeviceDataSourceProvider = MockDeviceDataSourceProvider._();

final class MockDeviceDataSourceProvider
    extends
        $FunctionalProvider<
          MockDeviceDataSource,
          MockDeviceDataSource,
          MockDeviceDataSource
        >
    with $Provider<MockDeviceDataSource> {
  MockDeviceDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mockDeviceDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mockDeviceDataSourceHash();

  @$internal
  @override
  $ProviderElement<MockDeviceDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  MockDeviceDataSource create(Ref ref) {
    return mockDeviceDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MockDeviceDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MockDeviceDataSource>(value),
    );
  }
}

String _$mockDeviceDataSourceHash() =>
    r'7da443cdd325a040212556fec7f17b4d079a083a';
