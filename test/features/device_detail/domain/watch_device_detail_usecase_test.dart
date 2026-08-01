import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/device_detail/domain/entities/device_detail.dart';
import 'package:meca_lab/features/device_detail/domain/usecases/watch_device_detail_usecase.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late MockDeviceRepository repository;
  late WatchDeviceDetailUseCase useCase;

  setUp(() {
    repository = MockDeviceRepository();
    useCase = WatchDeviceDetailUseCase(repository);
  });

  final device = Device(
    id: 'dev-1',
    siteId: 'site-1',
    name: 'Compresor 1',
    type: DeviceType.compresor,
    status: DeviceStatus.online,
    lastConnection: DateTime(2026, 7, 31, 10),
    sensorCount: 2,
    keySensors: const [],
  );

  final sensors = [
    const Sensor(
      id: 'sensor-1',
      deviceId: 'dev-1',
      name: 'Temperatura motor',
      type: SensorType.temperatura,
      unit: '°C',
      currentValue: 65,
      safeMin: 0,
      safeMax: 90,
    ),
  ];

  test('emite Right con el dispositivo y su lista completa de sensores', () async {
    when(
      () => repository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => Stream.value(Right(device)));
    when(
      () => repository.getSensorsForDevice('dev-1'),
    ).thenAnswer((_) async => Right(sensors));

    await expectLater(
      useCase('dev-1'),
      emits(
        isA<Right<Failure, DeviceDetail>>().having(
          (right) => right.value,
          'value',
          isA<DeviceDetail>()
              .having((d) => d.device, 'device', device)
              .having((d) => d.sensors, 'sensors', sensors),
        ),
      ),
    );
  });

  test('emite Left cuando el dispositivo no se encuentra', () async {
    when(() => repository.watchDeviceById('missing')).thenAnswer(
      (_) => Stream.value(const Left(UnexpectedFailure('device not found'))),
    );

    await expectLater(
      useCase('missing'),
      emits(const Left<Failure, DeviceDetail>(UnexpectedFailure('device not found'))),
    );

    verifyNever(() => repository.getSensorsForDevice(any()));
  });

  test('emite Left cuando los sensores no están disponibles', () async {
    when(
      () => repository.watchDeviceById('dev-1'),
    ).thenAnswer((_) => Stream.value(Right(device)));
    when(() => repository.getSensorsForDevice('dev-1')).thenAnswer(
      (_) async => const Left(UnexpectedFailure('sensors unavailable')),
    );

    await expectLater(
      useCase('dev-1'),
      emits(const Left<Failure, DeviceDetail>(UnexpectedFailure('sensors unavailable'))),
    );
  });
}
