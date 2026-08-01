import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:meca_lab/features/auth/data/datasources/auth_mock_data_source.dart';
import 'package:meca_lab/features/auth/data/models/user_model.dart';
import 'package:meca_lab/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthMockDataSource extends Mock implements AuthMockDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthMockDataSource mockDataSource;
  late MockAuthLocalDataSource localDataSource;
  late AuthRepositoryImpl repository;

  const userModel = UserModel(
    id: 'usr-1',
    email: 'camila.rios@plantademo.meclab',
    name: 'Camila Ríos',
    role: UserRole.operador,
  );

  setUpAll(() {
    registerFallbackValue(userModel);
  });

  setUp(() {
    mockDataSource = MockAuthMockDataSource();
    localDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      mockDataSource: mockDataSource,
      localDataSource: localDataSource,
    );
  });

  test('login válido guarda la sesión y devuelve Right(User)', () async {
    when(
      () => mockDataSource.validateCredentials(
        email: userModel.email,
        password: 'operador123',
      ),
    ).thenAnswer((_) async => userModel);
    when(() => localDataSource.saveSession(userModel))
        .thenAnswer((_) async {});

    final result = await repository.login(
      email: userModel.email,
      password: 'operador123',
    );

    final user = result.getOrElse((_) => fail('expected a Right'));
    expect(user.id, userModel.id);
    expect(user.email, userModel.email);
    expect(user.name, userModel.name);
    expect(user.role, userModel.role);
    verify(() => localDataSource.saveSession(userModel)).called(1);
  });

  test(
    'login inválido devuelve Left(InvalidCredentialsFailure) y no persiste nada',
    () async {
      when(
        () => mockDataSource.validateCredentials(
          email: userModel.email,
          password: 'incorrecta',
        ),
      ).thenAnswer((_) async => null);

      final result = await repository.login(
        email: userModel.email,
        password: 'incorrecta',
      );

      expect(result, const Left<Failure, User>(InvalidCredentialsFailure()));
      verifyNever(() => localDataSource.saveSession(any()));
    },
  );

  test(
    'getCurrentSession devuelve Right(User) cuando hay sesión persistida',
    () async {
      when(() => localDataSource.getSession())
          .thenAnswer((_) async => userModel);

      final result = await repository.getCurrentSession();

      final user = result.getOrElse((_) => fail('expected a Right'));
      expect(user.id, userModel.id);
      expect(user.email, userModel.email);
      expect(user.name, userModel.name);
      expect(user.role, userModel.role);
    },
  );

  test(
    'getCurrentSession devuelve Left(NoSessionFailure) cuando no hay sesión',
    () async {
      when(() => localDataSource.getSession()).thenAnswer((_) async => null);

      final result = await repository.getCurrentSession();

      expect(result, const Left<Failure, User>(NoSessionFailure()));
    },
  );

  test('logout limpia la sesión y devuelve Right(null)', () async {
    when(() => localDataSource.clearSession()).thenAnswer((_) async {});

    final result = await repository.logout();

    expect(result, const Right<Failure, void>(null));
    verify(() => localDataSource.clearSession()).called(1);
  });
}
