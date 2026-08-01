import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/sensor.dart';
import '../../domain/entities/sensor_history_range.dart';
import '../../domain/entities/site.dart';
import '../../domain/entities/tenant.dart';

part 'mock_device_data_source.g.dart';

/// How many readings [MockDeviceDataSource] keeps per sensor for the
/// device_detail sparkline. Bounded so memory doesn't grow for the life of
/// the session.
const int _historyBufferSize = 40;

/// A single history point for one sensor. Deliberately not the
/// `device_detail`-only `SensorReading` domain entity — `shared/data` must
/// not depend on a feature's `domain/` (dependency runs the other way).
/// `SensorHistoryRepositoryImpl` maps this to `SensorReading`, attaching the
/// sensor id the stream is already keyed by.
class SensorHistoryPoint {
  final DateTime timestamp;
  final double value;

  const SensorHistoryPoint({required this.timestamp, required this.value});
}

/// Session-wide source of truth for device/sensor mock data — every feature
/// that reads devices (dashboard, device_detail, alerts) goes through the
/// same instance, so they never disagree on state.
///
/// The single-instance guarantee comes from [mockDeviceDataSourceProvider]
/// being `keepAlive: true`, not from a manual static-singleton pattern here
/// — that keeps this class a plain, constructible, mockable unit for tests.
class MockDeviceDataSource {
  MockDeviceDataSource() {
    _seedHistory();
    _startSimulation();
  }

  static const tenant = Tenant(
    id: 'tenant-metalurgica-andina',
    name: 'Metalúrgica Andina S.A.S.',
  );

  static const site = Site(
    id: 'site-planta-principal',
    tenantId: 'tenant-metalurgica-andina',
    name: 'Planta Principal',
  );

  final Random _random = Random();
  final StreamController<List<Device>> _controller =
      StreamController<List<Device>>.broadcast();
  Timer? _timer;

  late final Map<String, List<Sensor>> _sensorsByDeviceId = _seedSensors();
  late List<Device> _devices = _seedDevices(_sensorsByDeviceId);

  final Map<String, List<SensorHistoryPoint>> _historyBySensorId = {};
  final Map<String, StreamController<List<SensorHistoryPoint>>>
  _historyControllers = {};

  /// Broadcasts the current device list on every simulated tick. New
  /// listeners get the current snapshot immediately instead of waiting for
  /// the next tick.
  Stream<List<Device>> get devicesStream => _controller.stream;

  List<Device> get currentDevices => List.unmodifiable(_devices);

  /// A device's full sensor list — unlike [Device.keySensors] (a 1-2 sensor
  /// dashboard snapshot), this is every sensor `device_detail` needs.
  /// Returns an empty list for an unknown [deviceId].
  List<Sensor> sensorsForDevice(String deviceId) =>
      List.unmodifiable(_sensorsByDeviceId[deviceId] ?? const []);

  /// Emits a sensor's bounded reading history on every simulated tick. New
  /// listeners get the current buffer immediately, same as [devicesStream].
  Stream<List<SensorHistoryPoint>> historyStream(String sensorId) {
    final existing = _historyControllers[sensorId];
    if (existing != null) return existing.stream;

    late final StreamController<List<SensorHistoryPoint>> controller;
    controller = StreamController<List<SensorHistoryPoint>>.broadcast(
      onListen: () => controller.add(_historyFor(sensorId)),
    );
    _historyControllers[sensorId] = controller;
    return controller.stream;
  }

  List<SensorHistoryPoint> _historyFor(String sensorId) =>
      List.unmodifiable(_historyBySensorId[sensorId] ?? const []);

  /// Synthetic historical points for a coarser [range] (day/week/month) —
  /// unrelated to the live tick buffer behind [historyStream]. Returns an
  /// empty list for an unknown [sensorId]. Seeded per `(sensorId, range)` so
  /// repeated calls (e.g. switching the range picker back and forth) return
  /// the same series instead of a fresh random walk each time.
  List<SensorHistoryPoint> generateHistoryForRange(
    String sensorId,
    SensorHistoryRange range,
  ) {
    final sensor = _findSensor(sensorId);
    if (sensor == null) return const [];

    final (pointCount, step) = switch (range) {
      SensorHistoryRange.day => (24, const Duration(hours: 1)),
      SensorHistoryRange.week => (7, const Duration(days: 1)),
      SensorHistoryRange.month => (30, const Duration(days: 1)),
    };

    final now = DateTime.now();
    final walkRandom = Random(sensorId.hashCode ^ range.index);
    final safeSpan = sensor.safeMax - sensor.safeMin;
    var value = sensor.currentValue;

    final points = <SensorHistoryPoint>[];
    for (var i = 0; i < pointCount; i++) {
      final noise = (walkRandom.nextDouble() * 2 - 1) * safeSpan * 0.05;
      value = (value + noise).clamp(sensor.safeMin, sensor.safeMax);
      points.add(
        SensorHistoryPoint(
          timestamp: now.subtract(step * (pointCount - 1 - i)),
          value: value,
        ),
      );
    }
    return List.unmodifiable(points);
  }

  Sensor? _findSensor(String sensorId) {
    for (final sensors in _sensorsByDeviceId.values) {
      for (final sensor in sensors) {
        if (sensor.id == sensorId) return sensor;
      }
    }
    return null;
  }

  void _seedHistory() {
    final now = DateTime.now();
    for (final sensors in _sensorsByDeviceId.values) {
      for (final sensor in sensors) {
        _historyBySensorId[sensor.id] = [
          SensorHistoryPoint(timestamp: now, value: sensor.currentValue),
        ];
      }
    }
  }

  void _startSimulation() {
    _controller.onListen = () => _controller.add(currentDevices);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) => _tick());
  }

  void _tick() {
    for (final deviceId in _sensorsByDeviceId.keys) {
      final isOffline =
          _devices.firstWhere((d) => d.id == deviceId).status ==
          DeviceStatus.offline;
      if (isOffline) continue;

      _sensorsByDeviceId[deviceId] = [
        for (final sensor in _sensorsByDeviceId[deviceId]!)
          _isOutOfSafeRange(sensor) ? sensor : _jitter(sensor),
      ];

      for (final sensor in _sensorsByDeviceId[deviceId]!) {
        _recordHistory(sensor);
      }
    }

    _devices = [
      for (final device in _devices)
        device.status == DeviceStatus.offline
            ? device
            : Device(
                id: device.id,
                siteId: device.siteId,
                name: device.name,
                type: device.type,
                status: device.status,
                lastConnection: DateTime.now(),
                sensorCount: device.sensorCount,
                keySensors: _sensorsByDeviceId[device.id]!,
              ),
    ];

    _controller.add(currentDevices);
  }

  void _recordHistory(Sensor sensor) {
    final history = _historyBySensorId.putIfAbsent(sensor.id, () => []);
    history.add(
      SensorHistoryPoint(timestamp: DateTime.now(), value: sensor.currentValue),
    );
    if (history.length > _historyBufferSize) {
      history.removeAt(0);
    }
    _historyControllers[sensor.id]?.add(List.unmodifiable(history));
  }

  /// A sensor already outside its safe range stays there — this is how the
  /// critical device's flagged sensor never flickers back into range.
  bool _isOutOfSafeRange(Sensor sensor) =>
      sensor.currentValue < sensor.safeMin || sensor.currentValue > sensor.safeMax;

  Sensor _jitter(Sensor sensor) {
    final range = sensor.safeMax - sensor.safeMin;
    final noise = (_random.nextDouble() * 2 - 1) * range * 0.02;
    final next = (sensor.currentValue + noise).clamp(
      sensor.safeMin,
      sensor.safeMax,
    );
    return Sensor(
      id: sensor.id,
      deviceId: sensor.deviceId,
      name: sensor.name,
      type: sensor.type,
      unit: sensor.unit,
      currentValue: next,
      safeMin: sensor.safeMin,
      safeMax: sensor.safeMax,
    );
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
    for (final controller in _historyControllers.values) {
      controller.close();
    }
  }

  static List<Device> _seedDevices(Map<String, List<Sensor>> sensorsByDeviceId) {
    final now = DateTime.now();

    Device device({
      required String id,
      required String name,
      required DeviceType type,
      required DeviceStatus status,
      required DateTime lastConnection,
    }) {
      final sensors = sensorsByDeviceId[id]!;
      return Device(
        id: id,
        siteId: site.id,
        name: name,
        type: type,
        status: status,
        lastConnection: lastConnection,
        sensorCount: sensors.length,
        keySensors: sensors,
      );
    }

    return [
      device(
        id: 'device-compresor-norte',
        name: 'Compresor Norte',
        type: DeviceType.compresor,
        status: DeviceStatus.online,
        lastConnection: now,
      ),
      device(
        id: 'device-motor-linea-3',
        name: 'Motor Línea 3',
        type: DeviceType.motor,
        status: DeviceStatus.online,
        lastConnection: now,
      ),
      device(
        id: 'device-banda-transportadora-2',
        name: 'Banda Transportadora 2',
        type: DeviceType.banda,
        status: DeviceStatus.warning,
        lastConnection: now,
      ),
      device(
        id: 'device-bomba-sur',
        name: 'Bomba Sur',
        type: DeviceType.bomba,
        status: DeviceStatus.critical,
        lastConnection: now,
      ),
      device(
        id: 'device-motor-backup',
        name: 'Motor Backup',
        type: DeviceType.motor,
        status: DeviceStatus.offline,
        lastConnection: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  static Map<String, List<Sensor>> _seedSensors() => {
    'device-compresor-norte': const [
      Sensor(
        id: 'sensor-compresor-norte-temp',
        deviceId: 'device-compresor-norte',
        name: 'Temperatura',
        type: SensorType.temperatura,
        unit: '°C',
        currentValue: 62,
        safeMin: 20,
        safeMax: 90,
      ),
      Sensor(
        id: 'sensor-compresor-norte-presion',
        deviceId: 'device-compresor-norte',
        name: 'Presión',
        type: SensorType.presion,
        unit: 'bar',
        currentValue: 5.2,
        safeMin: 1,
        safeMax: 8,
      ),
    ],
    'device-motor-linea-3': const [
      Sensor(
        id: 'sensor-motor-linea-3-vibracion',
        deviceId: 'device-motor-linea-3',
        name: 'Vibración',
        type: SensorType.vibracion,
        unit: 'mm/s',
        currentValue: 1.8,
        safeMin: 0,
        safeMax: 4.5,
      ),
      Sensor(
        id: 'sensor-motor-linea-3-rpm',
        deviceId: 'device-motor-linea-3',
        name: 'RPM',
        type: SensorType.rpm,
        unit: 'rpm',
        currentValue: 1450,
        safeMin: 0,
        safeMax: 3000,
      ),
    ],
    'device-banda-transportadora-2': const [
      Sensor(
        id: 'sensor-banda-transportadora-2-vibracion',
        deviceId: 'device-banda-transportadora-2',
        name: 'Vibración',
        type: SensorType.vibracion,
        unit: 'mm/s',
        currentValue: 4.1,
        safeMin: 0,
        safeMax: 4.5,
      ),
      Sensor(
        id: 'sensor-banda-transportadora-2-corriente',
        deviceId: 'device-banda-transportadora-2',
        name: 'Corriente',
        type: SensorType.corriente,
        unit: 'A',
        currentValue: 18,
        safeMin: 0,
        safeMax: 40,
      ),
    ],
    'device-bomba-sur': const [
      Sensor(
        id: 'sensor-bomba-sur-presion',
        deviceId: 'device-bomba-sur',
        name: 'Presión',
        type: SensorType.presion,
        unit: 'bar',
        currentValue: 9.4,
        safeMin: 1,
        safeMax: 8,
      ),
      Sensor(
        id: 'sensor-bomba-sur-temp',
        deviceId: 'device-bomba-sur',
        name: 'Temperatura',
        type: SensorType.temperatura,
        unit: '°C',
        currentValue: 58,
        safeMin: 20,
        safeMax: 90,
      ),
    ],
    'device-motor-backup': const [
      Sensor(
        id: 'sensor-motor-backup-temp',
        deviceId: 'device-motor-backup',
        name: 'Temperatura',
        type: SensorType.temperatura,
        unit: '°C',
        currentValue: 24,
        safeMin: 20,
        safeMax: 90,
      ),
      Sensor(
        id: 'sensor-motor-backup-corriente',
        deviceId: 'device-motor-backup',
        name: 'Corriente',
        type: SensorType.corriente,
        unit: 'A',
        currentValue: 0,
        safeMin: 0,
        safeMax: 40,
      ),
    ],
  };
}

@Riverpod(keepAlive: true)
MockDeviceDataSource mockDeviceDataSource(Ref ref) {
  final dataSource = MockDeviceDataSource();
  ref.onDispose(dataSource.dispose);
  return dataSource;
}
