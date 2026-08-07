import 'dart:async';

import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/core/router/app_router.dart';
import 'package:meca_lab/features/device_detail/presentation/widgets/device_recent_alerts_section.dart';
import 'package:meca_lab/shared/data/repositories/mock_alert_repository_impl.dart';
import 'package:meca_lab/shared/domain/entities/alert.dart';
import 'package:meca_lab/shared/domain/repositories/alert_repository.dart';
import 'package:meca_lab/shared/widgets/alert_severity_badge.dart';
import 'package:mocktail/mocktail.dart';

class MockAlertRepository extends Mock implements AlertRepository {}

void main() {
  late MockAlertRepository repository;

  setUp(() async {
    repository = MockAlertRepository();
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Alert buildAlert({
    required String id,
    String deviceId = 'dev-1',
    AlertSeverity severity = AlertSeverity.warning,
    DateTime? timestamp,
  }) => Alert(
    id: id,
    deviceId: deviceId,
    deviceName: 'Compresor Norte',
    severity: severity,
    message: 'Mensaje de prueba',
    timestamp: timestamp ?? DateTime(2026, 8, 1, 10),
    status: AlertStatus.active,
  );

  // "Ver todas" usa context.push, que necesita un GoRouter real en el árbol
  // (MaterialApp(home: ...) no alcanza) — mismo gotcha ya documentado para
  // el resto de la navegación de la app.
  Widget buildApp() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const Scaffold(body: DeviceRecentAlertsSection(deviceId: 'dev-1')),
        ),
        GoRoute(
          path: AppRoutes.alerts,
          builder: (context, state) =>
              const Scaffold(body: Text('Pantalla de alertas')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [alertRepositoryImplProvider.overrideWithValue(repository)],
      child: AppThemeProvider(child: MaterialApp.router(routerConfig: router)),
    );
  }

  testWidgets('loading no muestra alertas todavía', (tester) async {
    final completer = Completer<Either<Failure, List<Alert>>>();
    when(() => repository.getAlerts()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(AlertSeverityBadge), findsNothing);
    expect(find.text('Sin alertas activas'), findsNothing);
  });

  testWidgets('éxito muestra una card por alerta reciente', (tester) async {
    final alerts = [
      buildAlert(id: 'a1'),
      buildAlert(id: 'a2', severity: AlertSeverity.critical),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertSeverityBadge), findsNWidgets(2));
  });

  testWidgets('vacío muestra "Sin alertas activas"', (tester) async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Right(<Alert>[]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Sin alertas activas'), findsOneWidget);
  });

  testWidgets('error muestra el estado de error', (tester) async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('boom')));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las alertas'), findsOneWidget);
  });

  testWidgets('"Ver todas" navega a /alerts', (tester) async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Right(<Alert>[]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ver todas').first);
    await tester.pumpAndSettle();

    expect(find.text('Pantalla de alertas'), findsOneWidget);
  });
}
