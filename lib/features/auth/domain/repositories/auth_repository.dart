import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Returns `Left(InvalidCredentialsFailure())` when [email]/[password]
  /// don't match a known test user.
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  /// Returns `Left(NoSessionFailure())` when there's no persisted session.
  Future<Either<Failure, User>> getCurrentSession();
}
