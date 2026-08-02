import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/dashboard/domain/usecases/watch_devices_usecase.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late MockDeviceRepository repository;
  late WatchDevicesUseCase useCase;

  setUp(() {
    repository = MockDeviceRepository();
    useCase = WatchDevicesUseCase(repository);
  });

  final devices = [
    Device(
      id: 'dev-1',
      siteId: 'site-1',
      name: 'Compresor 1',
      type: DeviceType.compresor,
      status: DeviceStatus.online,
      lastConnection: DateTime(2026, 7, 31, 10),
      sensorCount: 2,
      keySensors: const [],
    ),
  ];

  test('emite Right con la lista de dispositivos', () async {
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => Stream.value(Right(devices)));

    await expectLater(useCase(), emits(Right<Failure, List<Device>>(devices)));
  });

  test('emite Left cuando el repositorio falla', () async {
    when(
      () => repository.watchDevices(),
    ).thenAnswer((_) => Stream.value(const Left(UnexpectedFailure('boom'))));

    await expectLater(
      useCase(),
      emits(const Left<Failure, List<Device>>(UnexpectedFailure('boom'))),
    );
  });
}
