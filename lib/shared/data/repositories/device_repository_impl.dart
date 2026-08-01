import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/failures.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/sensor.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/mock_device_data_source.dart';

part 'device_repository_impl.g.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final MockDeviceDataSource dataSource;

  const DeviceRepositoryImpl(this.dataSource);

  @override
  Stream<Either<Failure, List<Device>>> watchDevices() async* {
    try {
      await for (final devices in dataSource.devicesStream) {
        yield Right(devices);
      }
    } catch (e) {
      yield Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Device>> watchDeviceById(String id) async* {
    try {
      await for (final devices in dataSource.devicesStream) {
        final matches = devices.where((device) => device.id == id);
        if (matches.isEmpty) {
          yield Left(UnexpectedFailure('device not found: $id'));
        } else {
          yield Right(matches.first);
        }
      }
    } catch (e) {
      yield Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Sensor>>> getSensorsForDevice(
    String deviceId,
  ) async {
    try {
      return Right(dataSource.sensorsForDevice(deviceId));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}

@Riverpod(keepAlive: true)
DeviceRepository deviceRepositoryImpl(Ref ref) {
  final dataSource = ref.watch(mockDeviceDataSourceProvider);
  return DeviceRepositoryImpl(dataSource);
}
