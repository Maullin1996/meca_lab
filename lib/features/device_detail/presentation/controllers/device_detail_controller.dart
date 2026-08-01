import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/data/repositories/device_repository_impl.dart';
import '../../domain/entities/device_detail.dart';
import '../../domain/usecases/watch_device_detail_usecase.dart';

part 'device_detail_controller.g.dart';

/// A repository failure here isn't transient (the mock stream doesn't
/// recover), so retrying is just wasted work — same reasoning as
/// `DashboardController`.
Duration? _neverRetry(int retryCount, Object error) => null;

/// One controller instance per `deviceId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, so each device_detail screen
/// gets its own independent stream/state instead of sharing one.
///
/// [DeviceDetail] (device + full sensor list) already is the plain state
/// widgets need — no extra wrapper class, unlike `DashboardState`, since
/// there's no UI-only field (search, filters) layered on top yet.
@Riverpod(retry: _neverRetry)
class DeviceDetailController extends _$DeviceDetailController {
  @override
  Stream<DeviceDetail> build(String deviceId) async* {
    final repository = ref.watch(deviceRepositoryImplProvider);
    final watchDeviceDetail = WatchDeviceDetailUseCase(repository);

    await for (final result in watchDeviceDetail(deviceId)) {
      yield result.fold((failure) => throw failure, (deviceDetail) => deviceDetail);
    }
  }
}
