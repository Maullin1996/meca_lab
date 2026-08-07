import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/data/repositories/mock_alert_repository_impl.dart';
import '../../../../shared/domain/entities/alert.dart';
import '../../domain/usecases/get_recent_alerts_for_device_usecase.dart';

part 'device_recent_alerts_controller.g.dart';

/// Read-only per `deviceId` — riverpod_generator infers the family from the
/// extra `build()` parameter, same as [sensorHistoryForRange]. A plain
/// function provider, not a `Notifier`, because this screen never mutates
/// alerts (no acknowledge here) — it only reads the top 5 recent
/// warning/critical alerts for its own device.
@riverpod
Future<List<Alert>> deviceRecentAlerts(Ref ref, String deviceId) async {
  final repository = ref.watch(alertRepositoryImplProvider);
  final useCase = GetRecentAlertsForDeviceUseCase(repository);
  final result = await useCase(deviceId);

  return result.fold((failure) => throw failure, (alerts) => alerts);
}
