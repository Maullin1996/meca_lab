import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  late MockDeviceRepository repository;

  setUp(() {
    repository = MockDeviceRepository();
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

  group('watchDeviceById', () {
    test('emite Right con el dispositivo', () async {
      when(
        () => repository.watchDeviceById('dev-1'),
      ).thenAnswer((_) => Stream.value(Right(device)));

      await expectLater(
        repository.watchDeviceById('dev-1'),
        emits(Right<Failure, Device>(device)),
      );
    });

    test('emite Left cuando el dispositivo no se encuentra', () async {
      when(() => repository.watchDeviceById('missing')).thenAnswer(
        (_) => Stream.value(const Left(UnexpectedFailure('device not found'))),
      );

      await expectLater(
        repository.watchDeviceById('missing'),
        emits(const Left<Failure, Device>(UnexpectedFailure('device not found'))),
      );
    });
  });

  group('getSensorsForDevice', () {
    test('devuelve Right con la lista completa de sensores', () async {
      when(
        () => repository.getSensorsForDevice('dev-1'),
      ).thenAnswer((_) async => Right(sensors));

      final result = await repository.getSensorsForDevice('dev-1');

      expect(result, Right<Failure, List<Sensor>>(sensors));
    });

    test('devuelve Left cuando los sensores no están disponibles', () async {
      when(() => repository.getSensorsForDevice('dev-1')).thenAnswer(
        (_) async => const Left(UnexpectedFailure('sensors unavailable')),
      );

      final result = await repository.getSensorsForDevice('dev-1');

      expect(
        result,
        const Left<Failure, List<Sensor>>(UnexpectedFailure('sensors unavailable')),
      );
    });
  });
}
