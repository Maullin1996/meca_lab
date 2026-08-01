import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSessionUseCase {
  final AuthRepository repository;

  const GetCurrentSessionUseCase(this.repository);

  Future<Either<Failure, User>> call() {
    return repository.getCurrentSession();
  }
}
