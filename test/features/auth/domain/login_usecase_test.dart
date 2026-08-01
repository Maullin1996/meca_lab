import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:meca_lab/features/auth/domain/repositories/auth_repository.dart';
import 'package:meca_lab/features/auth/domain/usecases/login_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LoginUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LoginUseCase(repository);
  });

  const user = User(
    id: '1',
    email: 'operador@meclab.demo',
    name: 'Operador Demo',
    role: UserRole.operador,
  );

  test('devuelve Right(User) cuando el login es exitoso', () async {
    when(
      () => repository.login(
        email: 'operador@meclab.demo',
        password: 'correcta',
      ),
    ).thenAnswer((_) async => const Right(user));

    final result = await useCase(
      email: 'operador@meclab.demo',
      password: 'correcta',
    );

    expect(result, const Right<Failure, User>(user));
    verify(
      () => repository.login(
        email: 'operador@meclab.demo',
        password: 'correcta',
      ),
    ).called(1);
  });

  test(
    'devuelve Left(InvalidCredentialsFailure) con credenciales inválidas',
    () async {
      when(
        () => repository.login(
          email: 'operador@meclab.demo',
          password: 'incorrecta',
        ),
      ).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      final result = await useCase(
        email: 'operador@meclab.demo',
        password: 'incorrecta',
      );

      expect(
        result,
        const Left<Failure, User>(InvalidCredentialsFailure()),
      );
    },
  );
}
