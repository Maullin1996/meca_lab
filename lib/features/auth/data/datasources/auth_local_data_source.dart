import 'dart:convert';

import '../../../../core/services/local_storage_service.dart';
import '../models/user_model.dart';

/// Only class allowed to know about session persistence details — the
/// repository (and everything above it) goes through this instead.
class AuthLocalDataSource {
  static const _sessionKey = 'auth_session';

  final LocalStorageService storage;

  const AuthLocalDataSource(this.storage);

  Future<void> saveSession(UserModel user) {
    return storage.setString(_sessionKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getSession() async {
    final raw = storage.getString(_sessionKey);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> clearSession() {
    return storage.remove(_sessionKey);
  }
}
