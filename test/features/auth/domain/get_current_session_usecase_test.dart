import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/domain/entities/user.dart';
import 'package:meca_lab/features/auth/domain/repositories/auth_repository.dart';
import 'package:meca_lab/features/auth/domain/usecases/get_current_session_usecase.dart';
import 'package:meca_lab/shared/domain/entities/user_role.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late GetCurrentSessionUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = GetCurrentSessionUseCase(repository);
  });

  const user = User(
    id: '2',
    email: 'admin@meclab.demo',
    name: 'Admin Demo',
    role: UserRole.administrador,
  );

  test('devuelve Right(User) cuando hay una sesión persistida', () async {
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => const Right(user));

    final result = await useCase();

    expect(result, const Right<Failure, User>(user));
  });

  test('devuelve Left(NoSessionFailure) cuando no hay sesión guardada', () async {
    when(
      () => repository.getCurrentSession(),
    ).thenAnswer((_) async => const Left(NoSessionFailure()));

    final result = await useCase();

    expect(result, const Left<Failure, User>(NoSessionFailure()));
  });
}
