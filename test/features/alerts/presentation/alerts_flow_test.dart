import 'dart:async';

import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/alerts/data/repositories/mock_alert_repository_impl.dart';
import 'package:meca_lab/features/alerts/domain/entities/alert.dart';
import 'package:meca_lab/features/alerts/domain/repositories/alert_repository.dart';
import 'package:meca_lab/features/alerts/presentation/pages/alerts_page.dart';
import 'package:meca_lab/features/alerts/presentation/widgets/alert_list_item.dart';
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
    AlertSeverity severity = AlertSeverity.warning,
    AlertStatus status = AlertStatus.active,
  }) => Alert(
    id: id,
    deviceId: 'device-1',
    deviceName: 'Compresor Norte',
    severity: severity,
    message: 'Mensaje de prueba',
    timestamp: DateTime(2026, 8, 1, 10),
    status: status,
  );

  Widget buildApp() {
    return ProviderScope(
      overrides: [alertRepositoryImplProvider.overrideWithValue(repository)],
      child: const AppThemeProvider(child: MaterialApp(home: AlertsPage())),
    );
  }

  testWidgets('loading no muestra items', (tester) async {
    final completer = Completer<Either<Failure, List<Alert>>>();
    when(() => repository.getAlerts()).thenAnswer((_) => completer.future);

    await tester.pumpWidget(buildApp());
    await tester.pump();

    expect(find.byType(AlertListItem), findsNothing);
  });

  testWidgets('éxito muestra una card por alerta', (tester) async {
    final alerts = [
      buildAlert(id: 'a1'),
      buildAlert(id: 'a2', severity: AlertSeverity.critical),
    ];
    when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertListItem), findsNWidgets(2));
  });

  testWidgets('error muestra el estado de error', (tester) async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('boom')));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar las alertas'), findsOneWidget);
  });

  testWidgets('vacío muestra el estado vacío', (tester) async {
    when(
      () => repository.getAlerts(),
    ).thenAnswer((_) async => const Right(<Alert>[]));

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(
      find.text('Ninguna alerta coincide con los filtros'),
      findsOneWidget,
    );
  });

  group('filtros', () {
    testWidgets('filtro por severidad muestra solo esa severidad', (
      tester,
    ) async {
      final alerts = [
        buildAlert(id: 'a1', severity: AlertSeverity.critical),
        buildAlert(id: 'a2', severity: AlertSeverity.info),
      ];
      when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('severity-filter-critical')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('a1')), findsOneWidget);
      expect(find.byKey(const ValueKey('a2')), findsNothing);
    });

    testWidgets('filtro por severidad + estado combinados', (tester) async {
      final alerts = [
        buildAlert(
          id: 'a1',
          severity: AlertSeverity.critical,
          status: AlertStatus.active,
        ),
        buildAlert(
          id: 'a2',
          severity: AlertSeverity.critical,
          status: AlertStatus.resolved,
        ),
        buildAlert(
          id: 'a3',
          severity: AlertSeverity.info,
          status: AlertStatus.active,
        ),
      ];
      when(() => repository.getAlerts()).thenAnswer((_) async => Right(alerts));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('severity-filter-critical')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('status-filter-active')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('a1')), findsOneWidget);
      expect(find.byKey(const ValueKey('a2')), findsNothing);
      expect(find.byKey(const ValueKey('a3')), findsNothing);
    });
  });

  group('reconocer', () {
    testWidgets(
      'éxito: el botón desaparece de ese item sin recargar toda la lista',
      (tester) async {
        final alert = buildAlert(id: 'a1', status: AlertStatus.active);
        when(
          () => repository.getAlerts(),
        ).thenAnswer((_) async => Right([alert]));
        when(() => repository.acknowledgeAlert('a1')).thenAnswer(
          (_) async => Right(
            Alert(
              id: alert.id,
              deviceId: alert.deviceId,
              deviceName: alert.deviceName,
              sensorId: alert.sensorId,
              severity: alert.severity,
              message: alert.message,
              timestamp: alert.timestamp,
              status: AlertStatus.acknowledged,
            ),
          ),
        );

        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('acknowledge-a1')), findsOneWidget);

        await tester.tap(find.byKey(const Key('acknowledge-a1')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('acknowledge-a1')), findsNothing);
        expect(find.text('Alerta reconocida.'), findsOneWidget);
        verify(() => repository.getAlerts()).called(1);
      },
    );

    testWidgets('error: AppSnackBar de error visible, el item no cambia', (
      tester,
    ) async {
      final alert = buildAlert(id: 'a1', status: AlertStatus.active);
      when(
        () => repository.getAlerts(),
      ).thenAnswer((_) async => Right([alert]));
      when(
        () => repository.acknowledgeAlert('a1'),
      ).thenAnswer((_) async => const Left(NotFoundFailure('not found')));

      await tester.pumpWidget(buildApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('acknowledge-a1')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'No pudimos encontrar esa alerta. Es posible que ya no exista.',
        ),
        findsOneWidget,
      );
      expect(find.byKey(const Key('acknowledge-a1')), findsOneWidget);
    });
  });
}
