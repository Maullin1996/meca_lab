import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrap-only provider: `main()` resolves the real [SharedPreferences]
/// instance before `runApp` and overrides this via `ProviderScope.overrides`.
/// Everything downstream of this stays on `@riverpod` codegen.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp',
  );
});
