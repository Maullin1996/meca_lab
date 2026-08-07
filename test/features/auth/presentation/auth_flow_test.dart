import 'package:atomic_design/config/atomic_design_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:meca_lab/app.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/data/providers/auth_repository_provider.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:meca_lab/features/auth/domain/repositories/auth_repository.dart';
import 'package:meca_lab/features/auth/presentation/pages/login_mobile_view.dart';
import 'package:meca_lab/features/auth/presentation/pages/login_web_view.dart';
import 'package:meca_lab/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:meca_lab/shared/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;

  const user = User(
    id: 'usr-1',
    email: 'camila.rios@plantademo.meclab',
    name: 'Camila Ríos',
    role: UserRole.operador,
  );

  const mobileSize = Size(390, 844);
  const webSize = Size(1280, 800);

  setUp(() async {
    repository = MockAuthRepository();
    await AtomicDesignConfig.initializeFromAsset(
      'assets/config/app_config.json',
    );
  });

  Widget buildApp() {
    return ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const App(),
    );
  }

  Future<void> setSurfaceSize(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.binding.setSurfaceSize(null);
    });
  }

  Future<void> enterCredentials(
    WidgetTester tester,
    String email,
    String password,
  ) async {
    await tester.enterText(find.byType(TextFormField).at(0), email);
    await tester.enterText(find.byType(TextFormField).at(1), password);
    await tester.tap(find.text('Ingresar'));
  }

  testWidgets('ancho angosto renderiza LoginMobileView', (tester) async {
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => const Left(NoSessionFailure()));

    await setSurfaceSize(tester, mobileSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginMobileView), findsOneWidget);
    expect(find.byType(LoginWebView), findsNothing);
  });

  testWidgets('ancho ancho renderiza LoginWebView', (tester) async {
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => const Left(NoSessionFailure()));

    await setSurfaceSize(tester, webSize);
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(LoginWebView), findsOneWidget);
    expect(find.byType(LoginMobileView), findsNothing);
  });

  for (final variant in [
    (name: 'mobile', size: mobileSize),
    (name: 'web', size: webSize),
  ]) {
    group('flujo de login — variante ${variant.name}', () {
      testWidgets('login exitoso navega a DashboardPage', (tester) async {
        when(
          () => repository.getCurrentSession(),
        ).thenAnswer((_) async => const Left(NoSessionFailure()));
        when(
          () => repository.login(email: user.email, password: 'operador123'),
        ).thenAnswer((_) async => const Right(user));

        await setSurfaceSize(tester, variant.size);
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        await enterCredentials(tester, user.email, 'operador123');
        await tester.pumpAndSettle();

        expect(find.byType(DashboardPage), findsOneWidget);
      });

      testWidgets('login fallido muestra el error en el form', (
        tester,
      ) async {
        when(
          () => repository.getCurrentSession(),
        ).thenAnswer((_) async => const Left(NoSessionFailure()));
        when(
          () => repository.login(email: user.email, password: 'incorrecta'),
        ).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

        await setSurfaceSize(tester, variant.size);
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        await enterCredentials(tester, user.email, 'incorrecta');
        await tester.pumpAndSettle();

        expect(find.text('Email o contraseña incorrectos.'), findsOneWidget);
        expect(find.byType(DashboardPage), findsNothing);
      });

      testWidgets('logout vuelve a LoginPage', (tester) async {
        when(
          () => repository.getCurrentSession(),
        ).thenAnswer((_) async => const Right(user));
        when(
          () => repository.logout(),
        ).thenAnswer((_) async => const Right(null));

        await setSurfaceSize(tester, variant.size);
        await tester.pumpWidget(buildApp());
        await tester.pumpAndSettle();

        expect(find.byType(DashboardPage), findsOneWidget);

        await tester.tap(find.byKey(const Key('logout-button')));
        await tester.pumpAndSettle();

        expect(find.byType(DashboardPage), findsNothing);
        expect(find.text('Ingresar'), findsOneWidget);
      });
    });
  }
}
