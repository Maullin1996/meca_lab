import 'dart:async';

import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/data/providers/auth_repository_provider.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:meca_lab/features/auth/domain/repositories/auth_repository.dart';
import 'package:meca_lab/features/auth/presentation/controllers/auth_controller.dart';
import 'package:meca_lab/features/device_detail/presentation/controllers/device_detail_controller.dart';
import 'package:meca_lab/features/setpoints/data/repositories/mock_setpoint_repository_impl.dart';
import 'package:meca_lab/features/setpoints/domain/entities/setpoint.dart';
import 'package:meca_lab/features/setpoints/domain/repositories/setpoint_repository.dart';
import 'package:meca_lab/features/setpoints/presentation/widgets/setpoint_edit_sheet.dart';
import 'package:meca_lab/shared/data/repositories/device_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/user_role.dart';
import 'package:meca_lab/shared/domain/repositories/device_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockSetpointRepository extends Mock implements SetpointRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockDeviceRepository extends Mock implements DeviceRepository {}

void main() {
  // verifyNever(...any(named: 'requestingRole')...) needs a fallback value
  // registered for UserRole before it can build the argument matcher.
  setUpAll(() {
    registerFallbackValue(UserRole.operador);
  });

  late MockSetpointRepository setpointRepository;
  late MockAuthRepository authRepository;
  late MockDeviceRepository deviceRepository;

  const adminUser = User(
    id: 'usr-2',
    email: 'andres.torres@plantademo.meclab',
    name: 'Andrés Torres',
    role: UserRole.administrador,
  );

  final setpoint = Setpoint(
    id: 'setpoint-sensor-1',
    deviceId: 'device-1',
    sensorId: 'sensor-1',
    min: 20,
    max: 90,
    unit: '°C',
    updatedBy: 'Configuración inicial de fábrica',
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() async {
    setpointRepository = MockSetpointRepository();
    authRepository = MockAuthRepository();
    deviceRepository = MockDeviceRepository();

    when(
      () => authRepository.getCurrentSession(),
    ).thenAnswer((_) async => const Right(adminUser));
    when(
      () => deviceRepository.watchDeviceById('device-1'),
    ).thenAnswer((_) => const Stream.empty());

    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [
        setpointRepositoryImplProvider.overrideWithValue(setpointRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        deviceRepositoryImplProvider.overrideWithValue(deviceRepository),
      ],
      child: AppThemeProvider(
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                // Keeps deviceDetailControllerProvider('device-1') alive so
                // we can verify it gets re-subscribed (via
                // watchDeviceById) after save() invalidates it. Also warms
                // up authControllerProvider — in the real app this is
                // already resolved by the time a sensor card's edit icon
                // is visible (SensorDetailCard watches it too), but
                // nothing else in this test tree does.
                ref.watch(deviceDetailControllerProvider('device-1'));
                ref.watch(authControllerProvider);
                return ElevatedButton(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const SetpointEditSheet(sensorId: 'sensor-1'),
                  ),
                  child: const Text('abrir'),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  testWidgets('loading muestra un indicador de carga', (tester) async {
    final completer = Completer<Either<Failure, Setpoint>>();
    when(
      () => setpointRepository.getSetpointForSensor('sensor-1'),
    ).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildApp());
    await tester.tap(find.text('abrir'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('con datos prellena los campos min/max', (tester) async {
    when(
      () => setpointRepository.getSetpointForSensor('sensor-1'),
    ).thenAnswer((_) async => Right(setpoint));

    await openSheet(tester);

    expect(find.widgetWithText(TextFormField, '20.0'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '90.0'), findsOneWidget);
  });

  testWidgets(
    'validación inline: min >= max rechaza sin abrir el diálogo de confirmación',
    (tester) async {
      when(
        () => setpointRepository.getSetpointForSensor('sensor-1'),
      ).thenAnswer((_) async => Right(setpoint));

      await openSheet(tester);

      await tester.enterText(
        find.widgetWithText(TextFormField, '20.0'),
        '100',
      );
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('El mínimo debe ser menor que el máximo'), findsOneWidget);
      expect(find.text('Confirmar cambio'), findsNothing);
      verifyNever(
        () => setpointRepository.updateSetpoint(
          sensorId: any(named: 'sensorId'),
          min: any(named: 'min'),
          max: any(named: 'max'),
          requestingRole: any(named: 'requestingRole'),
          requestingUserDisplayName: any(named: 'requestingUserDisplayName'),
        ),
      );
    },
  );

  testWidgets(
    'flujo feliz: confirma, guarda, cierra el sheet, snackbar de éxito e invalida device_detail',
    (tester) async {
      when(
        () => setpointRepository.getSetpointForSensor('sensor-1'),
      ).thenAnswer((_) async => Right(setpoint));
      when(
        () => setpointRepository.updateSetpoint(
          sensorId: 'sensor-1',
          min: 15,
          max: 95,
          requestingRole: UserRole.administrador,
          requestingUserDisplayName: 'Andrés Torres',
        ),
      ).thenAnswer(
        (_) async => Right(
          Setpoint(
            id: setpoint.id,
            deviceId: setpoint.deviceId,
            sensorId: setpoint.sensorId,
            min: 15,
            max: 95,
            unit: setpoint.unit,
            updatedBy: 'Andrés Torres',
            updatedAt: DateTime(2026, 8, 7),
          ),
        ),
      );

      await openSheet(tester);

      await tester.enterText(find.widgetWithText(TextFormField, '20.0'), '15');
      await tester.enterText(find.widgetWithText(TextFormField, '90.0'), '95');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar cambio'), findsOneWidget);
      // watchDeviceById already ran once for the initial mount.
      verify(() => deviceRepository.watchDeviceById('device-1')).called(1);

      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('Confirmar cambio'), findsNothing);
      expect(find.byType(SetpointEditSheet), findsNothing);
      expect(find.text('Setpoint actualizado.'), findsOneWidget);
      // invalidate() forces a second subscription — proof the card's
      // provider was actually invalidated, not just left stale.
      verify(() => deviceRepository.watchDeviceById('device-1')).called(1);
    },
  );

  group('errores de guardado — el sheet queda abierto con lo que se escribió', () {
    Future<void> saveAndExpectError(
      WidgetTester tester,
      Failure failure,
      String expectedMessage,
    ) async {
      when(
        () => setpointRepository.getSetpointForSensor('sensor-1'),
      ).thenAnswer((_) async => Right(setpoint));
      when(
        () => setpointRepository.updateSetpoint(
          sensorId: 'sensor-1',
          min: 15,
          max: 95,
          requestingRole: UserRole.administrador,
          requestingUserDisplayName: 'Andrés Torres',
        ),
      ).thenAnswer((_) async => Left(failure));

      await openSheet(tester);
      await tester.enterText(find.widgetWithText(TextFormField, '20.0'), '15');
      await tester.enterText(find.widgetWithText(TextFormField, '90.0'), '95');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.byType(SetpointEditSheet), findsOneWidget);
      expect(find.text(expectedMessage), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '95'), findsOneWidget);
    }

    testWidgets('UnauthorizedFailure', (tester) async {
      await saveAndExpectError(
        tester,
        const UnauthorizedFailure('no autorizado'),
        'No tienes permisos para realizar esta acción.',
      );
    });

    testWidgets('NotFoundFailure', (tester) async {
      await saveAndExpectError(
        tester,
        const NotFoundFailure('sensor not found'),
        'No pudimos encontrar el sensor solicitado.',
      );
    });

    testWidgets('ValidationFailure', (tester) async {
      await saveAndExpectError(
        tester,
        const ValidationFailure('El valor mínimo debe ser menor que el máximo.'),
        'El valor mínimo debe ser menor que el máximo.',
      );
    });

    testWidgets('UnexpectedFailure', (tester) async {
      await saveAndExpectError(
        tester,
        const UnexpectedFailure('boom'),
        'Ocurrió un error inesperado: boom',
      );
    });
  });

  testWidgets(
    'sin sesión activa muestra el mensaje correspondiente sin llamar a updateSetpoint',
    (tester) async {
      when(
        () => setpointRepository.getSetpointForSensor('sensor-1'),
      ).thenAnswer((_) async => Right(setpoint));
      when(
        () => authRepository.getCurrentSession(),
      ).thenAnswer((_) async => const Left(NoSessionFailure()));

      await openSheet(tester);
      await tester.enterText(find.widgetWithText(TextFormField, '20.0'), '15');
      await tester.enterText(find.widgetWithText(TextFormField, '90.0'), '95');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar'));
      await tester.pumpAndSettle();

      expect(find.text('No hay una sesión activa.'), findsOneWidget);
      verifyNever(
        () => setpointRepository.updateSetpoint(
          sensorId: any(named: 'sensorId'),
          min: any(named: 'min'),
          max: any(named: 'max'),
          requestingRole: any(named: 'requestingRole'),
          requestingUserDisplayName: any(named: 'requestingUserDisplayName'),
        ),
      );
    },
  );
}
