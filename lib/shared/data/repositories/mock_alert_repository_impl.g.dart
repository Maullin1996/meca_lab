// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_alert_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(alertRepositoryImpl)
final alertRepositoryImplProvider = AlertRepositoryImplProvider._();

final class AlertRepositoryImplProvider
    extends
        $FunctionalProvider<AlertRepository, AlertRepository, AlertRepository>
    with $Provider<AlertRepository> {
  AlertRepositoryImplProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'alertRepositoryImplProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$alertRepositoryImplHash();

  @$internal
  @override
  $ProviderElement<AlertRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AlertRepository create(Ref ref) {
    return alertRepositoryImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AlertRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AlertRepository>(value),
    );
  }
}

String _$alertRepositoryImplHash() =>
    r'c43a8660ab5f6d44ff2f8fc9d0e42ea40ffe1496';
