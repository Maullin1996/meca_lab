import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/local_storage_service.dart';
import 'shared_preferences_provider.dart';

part 'local_storage_service_provider.g.dart';

@riverpod
LocalStorageService localStorageService(Ref ref) {
  final preferences = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(preferences);
}
