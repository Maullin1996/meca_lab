import '../../domain/entities/user.dart';
import '../models/user_model.dart';

class _MockCredential {
  final UserModel user;
  final String password;

  const _MockCredential({required this.user, required this.password});
}

/// Fixed, pre-assigned list of demo users — there's no self-registration.
class AuthMockDataSource {
  static const _users = [
    _MockCredential(
      user: UserModel(
        id: 'usr-1',
        email: 'camila.rios@plantademo.meclab',
        name: 'Camila Ríos',
        role: UserRole.operador,
      ),
      password: 'operador123',
    ),
    _MockCredential(
      user: UserModel(
        id: 'usr-2',
        email: 'andres.torres@plantademo.meclab',
        name: 'Andrés Torres',
        role: UserRole.administrador,
      ),
      password: 'admin123',
    ),
  ];

  /// Returns the matching [UserModel], or `null` if [email]/[password]
  /// don't match any pre-assigned user.
  Future<UserModel?> validateCredentials({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    for (final credential in _users) {
      if (credential.user.email == email && credential.password == password) {
        return credential.user;
      }
    }
    return null;
  }
}
