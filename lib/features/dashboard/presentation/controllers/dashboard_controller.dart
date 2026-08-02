import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/data/repositories/device_repository_impl.dart';
import '../../../../shared/domain/entities/device.dart';
import '../../domain/usecases/watch_devices_usecase.dart';

part 'dashboard_controller.g.dart';

/// Plain state exposed to `presentation` widgets — no `Either`/`Failure`
/// leaks past this point. KPIs and the search filter are derived getters
/// over [devices] rather than a separate use case or duplicated per view.
class DashboardState {
  final List<Device> devices;
  final String searchQuery;

  const DashboardState({required this.devices, this.searchQuery = ''});

  List<Device> get filteredDevices {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return devices;
    return devices
        .where((device) => device.name.toLowerCase().contains(query))
        .toList();
  }

  int get totalDevices => devices.length;

  int get devicesInAlert => devices
      .where(
        (device) =>
            device.status == DeviceStatus.warning ||
            device.status == DeviceStatus.critical,
      )
      .length;

  int get activeSensors => devices
      .where((device) => device.status != DeviceStatus.offline)
      .fold(0, (sum, device) => sum + device.sensorCount);

  double get uptimePercentage {
    if (devices.isEmpty) return 0;
    final online = devices
        .where((device) => device.status != DeviceStatus.offline)
        .length;
    return online / devices.length * 100;
  }

  DashboardState copyWithQuery(String query) =>
      DashboardState(devices: devices, searchQuery: query);
}

/// A repository failure here isn't transient (the mock stream doesn't
/// recover), so retrying is just wasted work — Riverpod's default retry
/// policy (unlimited, exponential backoff) would otherwise keep resubscribing
/// forever.
Duration? _neverRetry(int retryCount, Object error) => null;

/// The only place in `presentation` that touches `Either`/`fpdart` — it
/// `.fold()`s each [WatchDevicesUseCase] emission into [DashboardState] for
/// widgets to consume directly. `build()` returns a `Stream` (not a
/// `Future`) because the use case itself is a live stream, which
/// riverpod_generator maps to a `StreamNotifier` — widgets still just see
/// `AsyncValue<DashboardState>` either way.
@Riverpod(retry: _neverRetry)
class DashboardController extends _$DashboardController {
  @override
  Stream<DashboardState> build() async* {
    final repository = ref.watch(deviceRepositoryImplProvider);
    final watchDevices = WatchDevicesUseCase(repository);

    await for (final result in watchDevices()) {
      // Read fresh on every tick so a running search isn't clobbered by the
      // next device-list emission from the mock stream.
      final query = state.value?.searchQuery ?? '';

      yield result.fold(
        (failure) => throw failure,
        (devices) => DashboardState(devices: devices, searchQuery: query),
      );
    }
  }

  void search(String query) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current.copyWithQuery(query));
  }
}
