// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mock_setpoint_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(setpointRepositoryImpl)
final setpointRepositoryImplProvider = SetpointRepositoryImplProvider._();

final class SetpointRepositoryImplProvider
    extends
        $FunctionalProvider<
          SetpointRepository,
          SetpointRepository,
          SetpointRepository
        >
    with $Provider<SetpointRepository> {
  SetpointRepositoryImplProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setpointRepositoryImplProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setpointRepositoryImplHash();

  @$internal
  @override
  $ProviderElement<SetpointRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SetpointRepository create(Ref ref) {
    return setpointRepositoryImpl(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetpointRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetpointRepository>(value),
    );
  }
}

String _$setpointRepositoryImplHash() =>
    r'e6508c17113bfe5b2bef09a8a88d7def6200298d';
