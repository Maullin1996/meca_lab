import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_mock_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthMockDataSource mockDataSource;
  final AuthLocalDataSource localDataSource;

  const AuthRepositoryImpl({
    required this.mockDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    final userModel = await mockDataSource.validateCredentials(
      email: email,
      password: password,
    );
    if (userModel == null) {
      return const Left(InvalidCredentialsFailure());
    }

    try {
      await localDataSource.saveSession(userModel);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
    return Right(userModel.toEntity());
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearSession();
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getCurrentSession() async {
    try {
      final userModel = await localDataSource.getSession();
      if (userModel == null) {
        return const Left(NoSessionFailure());
      }
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
