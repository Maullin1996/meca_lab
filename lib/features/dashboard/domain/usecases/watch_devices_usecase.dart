import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../shared/domain/entities/device.dart';
import '../../../../shared/domain/repositories/device_repository.dart';

/// Encapsulates which devices matter to the dashboard screen. Today that's
/// simply the repository's stream, but this is where future filtering or
/// ordering rules land without touching the repository or the UI.
class WatchDevicesUseCase {
  final DeviceRepository repository;

  const WatchDevicesUseCase(this.repository);

  Stream<Either<Failure, List<Device>>> call() {
    return repository.watchDevices();
  }
}
