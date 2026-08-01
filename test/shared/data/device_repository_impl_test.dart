import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/data/repositories/device_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
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
}
