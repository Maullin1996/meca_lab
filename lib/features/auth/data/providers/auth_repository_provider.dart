import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/providers/local_storage_service_provider.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_mock_data_source.dart';
import '../repositories/auth_repository_impl.dart';

part 'auth_repository_provider.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  final localStorageService = ref.watch(localStorageServiceProvider);
  return AuthRepositoryImpl(
    mockDataSource: AuthMockDataSource(),
    localDataSource: AuthLocalDataSource(localStorageService),
  );
}
