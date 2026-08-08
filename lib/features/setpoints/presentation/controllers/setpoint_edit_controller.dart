import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failures.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../device_detail/presentation/controllers/device_detail_controller.dart';
import '../../data/repositories/mock_setpoint_repository_impl.dart';
import '../../domain/entities/setpoint.dart';
import '../../domain/usecases/get_setpoint_for_sensor_usecase.dart';
import '../../domain/usecases/update_setpoint_usecase.dart';

part 'setpoint_edit_controller.g.dart';

/// Plain state exposed to `presentation` widgets — no `Either`/`Failure`
/// leaks past this point.
class SetpointEditState {
  final Setpoint setpoint;
  final double min;
  final double max;
  final bool isSaving;
  final String? errorMessage;

  const SetpointEditState({
    required this.setpoint,
    required this.min,
    required this.max,
    this.isSaving = false,
    this.errorMessage,
  });

  SetpointEditState copyWith({
    double? min,
    double? max,
    bool? isSaving,
    String? errorMessage,
  }) => SetpointEditState(
    setpoint: setpoint,
    min: min ?? this.min,
    max: max ?? this.max,
    isSaving: isSaving ?? false,
    errorMessage: errorMessage,
  );
}

/// One controller instance per `sensorId` — riverpod_generator infers the
/// family from `build()`'s extra parameter, same as `DeviceDetailController`
/// and `SensorHistoryRangeController`.
@riverpod
class SetpointEditController extends _$SetpointEditController {
  @override
  Future<SetpointEditState> build(String sensorId) async {
    final repository = ref.watch(setpointRepositoryImplProvider);
    final result = await GetSetpointForSensorUseCase(repository)(sensorId);

    return result.fold(
      (failure) => throw failure,
      (setpoint) =>
          SetpointEditState(setpoint: setpoint, min: setpoint.min, max: setpoint.max),
    );
  }

  /// Returns `null` on success, or a user-facing error message on failure —
  /// same contract as `AlertsController.acknowledgeAlert`. The sheet is
  /// expected to close itself and show a success snackbar when this
  /// resolves to `null`; otherwise it stays open and shows the message as
  /// an error snackbar.
  Future<String?> save(double min, double max) async {
    final current = state.value;
    if (current == null) return null;

    state = AsyncValue.data(
      current.copyWith(min: min, max: max, isSaving: true),
    );

    // The UI already hides the edit icon from anyone who isn't
    // `administrador`, so reaching here without a session is not expected
    // in practice — but this must not crash if it somehow happens, same
    // defensive criterion as the rest of the codebase.
    final user = ref.read(authControllerProvider).value?.user;
    if (user == null) {
      const message = 'No hay una sesión activa.';
      state = AsyncValue.data(
        current.copyWith(min: min, max: max, errorMessage: message),
      );
      return message;
    }

    final repository = ref.read(setpointRepositoryImplProvider);
    final result = await UpdateSetpointUseCase(repository)(
      sensorId: sensorId,
      min: min,
      max: max,
      requestingRole: user.role,
      requestingUserDisplayName: user.name,
    );

    return result.fold(
      (failure) {
        final message = _messageFor(failure);
        state = AsyncValue.data(
          current.copyWith(min: min, max: max, errorMessage: message),
        );
        return message;
      },
      (updatedSetpoint) {
        state = AsyncValue.data(current.copyWith(min: min, max: max));
        // Nudges device_detail's card to reflect the new range without
        // waiting for the mock's next 4s tick — no need to keep the
        // updated Setpoint in this controller's own state, the sheet
        // closes right after this resolves.
        ref.invalidate(
          deviceDetailControllerProvider(updatedSetpoint.deviceId),
        );
        return null;
      },
    );
  }

  String _messageFor(Failure failure) {
    return switch (failure) {
      InvalidCredentialsFailure() => 'Email o contraseña incorrectos.',
      NoSessionFailure() => 'No hay una sesión activa.',
      NotFoundFailure() => 'No pudimos encontrar el sensor solicitado.',
      UnauthorizedFailure() => 'No tienes permisos para realizar esta acción.',
      ValidationFailure(:final message) => message,
      UnexpectedFailure(:final message) =>
        'Ocurrió un error inesperado: $message',
    };
  }
}
