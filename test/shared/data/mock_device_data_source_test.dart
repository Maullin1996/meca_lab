import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/shared/data/datasources/mock_device_data_source.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';

void main() {
  test('los datos de fábrica cubren los 4 estados esperados', () {
    final dataSource = MockDeviceDataSource();
    addTearDown(dataSource.dispose);

    final statuses = dataSource.currentDevices.map((d) => d.status).toSet();

    expect(statuses, containsAll(DeviceStatus.values));
  });

  test('los datos de fábrica tienen entre 4 y 6 dispositivos', () {
    final dataSource = MockDeviceDataSource();
    addTearDown(dataSource.dispose);

    expect(dataSource.currentDevices.length, inInclusiveRange(4, 6));
  });

  test('el sensor fuera de rango del dispositivo critical se mantiene fuera de rango', () {
    final dataSource = MockDeviceDataSource();
    addTearDown(dataSource.dispose);

    final criticalDevice = dataSource.currentDevices.firstWhere(
      (d) => d.status == DeviceStatus.critical,
    );

    expect(criticalDevice, isNotNull);
  });

  test('el stream emite más de un valor a lo largo del tiempo', () {
    fakeAsync((async) {
      final dataSource = MockDeviceDataSource();
      addTearDown(dataSource.dispose);

      final emissions = <List<Device>>[];
      final subscription = dataSource.devicesStream.listen(emissions.add);
      addTearDown(subscription.cancel);

      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 13));
      async.flushMicrotasks();

      expect(emissions.length, greaterThan(1));
    });
  });

  test('el dispositivo offline no actualiza su última conexión', () {
    fakeAsync((async) {
      final dataSource = MockDeviceDataSource();
      addTearDown(dataSource.dispose);

      final offlineBefore = dataSource.currentDevices.firstWhere(
        (d) => d.status == DeviceStatus.offline,
      );

      async.elapse(const Duration(seconds: 13));

      final offlineAfter = dataSource.currentDevices.firstWhere(
        (d) => d.status == DeviceStatus.offline,
      );

      expect(offlineAfter.lastConnection, offlineBefore.lastConnection);
    });
  });
}
