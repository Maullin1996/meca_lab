import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over `shared_preferences` so the rest of the app depends on
/// this instead of the package directly.
class LocalStorageService {
  final SharedPreferences preferences;

  const LocalStorageService(this.preferences);

  String? getString(String key) => preferences.getString(key);

  Future<void> setString(String key, String value) {
    return preferences.setString(key, value);
  }

  Future<void> remove(String key) {
    return preferences.remove(key);
  }
}
