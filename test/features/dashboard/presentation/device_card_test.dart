import 'package:atomic_design/design_system.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/features/dashboard/presentation/widgets/device_card.dart';
import 'package:meca_lab/shared/data/repositories/sensor_history_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/device.dart';
import 'package:meca_lab/shared/domain/entities/sensor.dart';
import 'package:meca_lab/shared/domain/entities/sensor_reading.dart';
import 'package:meca_lab/shared/domain/repositories/sensor_history_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSensorHistoryRepository extends Mock
    implements SensorHistoryRepository {}

void main() {
  late MockSensorHistoryRepository historyRepository;

  const temperatura = Sensor(
    id: 'sensor-temp',
    deviceId: 'dev-1',
    name: 'Temperatura',
    type: SensorType.temperatura,
    unit: '°C',
    currentValue: 62,
    safeMin: 20,
    safeMax: 90,
  );

  const presion = Sensor(
    id: 'sensor-presion',
    deviceId: 'dev-1',
    name: 'Presión',
    type: SensorType.presion,
    unit: 'bar',
    currentValue: 5.2,
    safeMin: 1,
    safeMax: 8,
  );

  List<SensorReading> readingsFor(String sensorId) => [
    SensorReading(
      sensorId: sensorId,
      timestamp: DateTime(2026, 7, 31, 10),
      value: 60,
    ),
    SensorReading(
      sensorId: sensorId,
      timestamp: DateTime(2026, 7, 31, 10, 0, 4),
      value: 61,
    ),
  ];

  setUp(() async {
    historyRepository = MockSensorHistoryRepository();
    when(
      () => historyRepository.watchSensorHistory('sensor-temp'),
    ).thenAnswer((_) => Stream.value(Right(readingsFor('sensor-temp'))));
    when(
      () => historyRepository.watchSensorHistory('sensor-presion'),
    ).thenAnswer((_) => Stream.value(Right(readingsFor('sensor-presion'))));
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp(Device device) {
    return ProviderScope(
      overrides: [
        sensorHistoryRepositoryImplProvider.overrideWithValue(
          historyRepository,
        ),
      ],
      child: AppThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: DeviceCard(device: device, onTap: () {}),
          ),
        ),
      ),
    );
  }

  Device buildDevice(List<Sensor> sensors) => Device(
    id: 'dev-1',
    siteId: 'site-1',
    name: 'Compresor Norte',
    type: DeviceType.compresor,
    status: DeviceStatus.online,
    lastConnection: DateTime(2026, 7, 31, 10),
    sensorCount: sensors.length,
    keySensors: sensors,
  );

  testWidgets('con un solo sensor no muestra el menú de selección', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp(buildDevice(const [temperatura])));
    await tester.pumpAndSettle();

    expect(find.byType(PopupMenuButton<String>), findsNothing);
    expect(find.text('Historial: Temperatura'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets(
    'con dos sensores grafica el primero por defecto y permite cambiar con el menú',
    (tester) async {
      await tester.pumpWidget(
        buildApp(buildDevice(const [temperatura, presion])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
      expect(find.text('Historial: Temperatura'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Presión').last);
      await tester.pumpAndSettle();

      expect(find.text('Historial: Presión'), findsOneWidget);
      expect(find.text('Historial: Temperatura'), findsNothing);
      expect(find.byType(LineChart), findsOneWidget);
    },
  );
}
