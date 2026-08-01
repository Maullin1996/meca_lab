import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meca_lab/core/error/failures.dart';
import 'package:meca_lab/features/auth/domain/repositories/auth_repository.dart';
import 'package:meca_lab/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late LogoutUseCase useCase;

  setUp(() {
    repository = MockAuthRepository();
    useCase = LogoutUseCase(repository);
  });

  test('devuelve Right(null) cuando el logout es exitoso', () async {
    when(() => repository.logout()).thenAnswer((_) async => const Right(null));

    final result = await useCase();

    expect(result, const Right<Failure, void>(null));
    verify(() => repository.logout()).called(1);
  });

  test('devuelve Left(UnexpectedFailure) cuando el repositorio falla', () async {
    when(
      () => repository.logout(),
    ).thenAnswer((_) async => const Left(UnexpectedFailure('boom')));

    final result = await useCase();

    expect(result, const Left<Failure, void>(UnexpectedFailure('boom')));
  });
}
