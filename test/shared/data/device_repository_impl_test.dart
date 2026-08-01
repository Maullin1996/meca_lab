import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/data/repositories/device_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:mocktail/mocktail.dart';

class MockMockDeviceDataSource extends Mock implements MockDeviceDataSource {}

void main() {
  late MockMockDeviceDataSource dataSource;
  late DeviceRepositoryImpl repository;

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

  setUp(() {
    dataSource = MockMockDeviceDataSource();
    repository = DeviceRepositoryImpl(dataSource);
  });

  test('envuelve el stream del data source en Right', () async {
    when(
      () => dataSource.devicesStream,
    ).thenAnswer((_) => Stream.value(devices));

    await expectLater(
      repository.watchDevices(),
      emits(Right<Failure, List<Device>>(devices)),
    );
  });

  test('envuelve un error del stream en Left(UnexpectedFailure)', () async {
    when(
      () => dataSource.devicesStream,
    ).thenAnswer((_) => Stream<List<Device>>.error(Exception('boom')));

    await expectLater(
      repository.watchDevices(),
      emits(isA<Left<Failure, List<Device>>>()),
    );
  });

  group('watchDeviceById', () {
    test('emite Right con el dispositivo cuando existe en el stream', () async {
      when(
        () => dataSource.devicesStream,
      ).thenAnswer((_) => Stream.value(devices));

      await expectLater(
        repository.watchDeviceById('dev-1'),
        emits(Right<Failure, Device>(devices.first)),
      );
    });

    test('emite Left cuando el id no está en el stream', () async {
      when(
        () => dataSource.devicesStream,
      ).thenAnswer((_) => Stream.value(devices));

      await expectLater(
        repository.watchDeviceById('missing'),
        emits(isA<Left<Failure, Device>>()),
      );
    });

    test('envuelve un error del stream en Left(UnexpectedFailure)', () async {
      when(
        () => dataSource.devicesStream,
      ).thenAnswer((_) => Stream<List<Device>>.error(Exception('boom')));

      await expectLater(
        repository.watchDeviceById('dev-1'),
        emits(isA<Left<Failure, Device>>()),
      );
    });
  });

  group('getSensorsForDevice', () {
    final sensors = [
      const Sensor(
        id: 'sensor-1',
        deviceId: 'dev-1',
        name: 'Temperatura',
        type: SensorType.temperatura,
        unit: '°C',
        currentValue: 65,
        safeMin: 0,
        safeMax: 90,
      ),
    ];

    test('devuelve Right con la lista completa de sensores del data source', () async {
      when(
        () => dataSource.sensorsForDevice('dev-1'),
      ).thenReturn(sensors);

      final result = await repository.getSensorsForDevice('dev-1');

      expect(result, Right<Failure, List<Sensor>>(sensors));
    });

    test('envuelve una excepción del data source en Left(UnexpectedFailure)', () async {
      when(
        () => dataSource.sensorsForDevice('dev-1'),
      ).thenThrow(Exception('boom'));

      final result = await repository.getSensorsForDevice('dev-1');

      expect(result, isA<Left<Failure, List<Sensor>>>());
    });
  });
}
