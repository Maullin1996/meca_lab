import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/setpoint_edit_controller.dart';

/// Opened as a modal bottom sheet from `device_detail`'s `SensorDetailCard`
/// (only visible to an `administrador`) — `setpoints` has no route or
/// standalone screen of its own.
///
/// No prior `AppBottomSheet`/`AppDialog` usage exists elsewhere in the app
/// to follow as precedent (checked `alerts` and `login`) — this follows
/// each component's own documented `.show(...)` factory instead.
class SetpointEditSheet extends ConsumerStatefulWidget {
  final String sensorId;

  const SetpointEditSheet({super.key, required this.sensorId});

  @override
  ConsumerState<SetpointEditSheet> createState() => _SetpointEditSheetState();
}

class _SetpointEditSheetState extends ConsumerState<SetpointEditSheet> {
  final _formKey = GlobalKey<FormState>();
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  /// Prefills the text fields from the loaded `Setpoint` exactly once —
  /// guards against `build()` re-running (e.g. while `isSaving` toggles)
  /// from stomping over what the user is actively typing.
  bool _prefilled = false;

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ingresa un valor';
    if (double.tryParse(value) == null) return 'Debe ser un número';
    return null;
  }

  String? _maxValidator(String? value) {
    final numberError = _numberValidator(value);
    if (numberError != null) return numberError;

    final min = double.tryParse(_minController.text);
    final max = double.tryParse(value!);
    if (min != null && max != null && min >= max) {
      return 'El mínimo debe ser menor que el máximo';
    }
    return null;
  }

  void _handleSavePressed(String unit) {
    if (!_formKey.currentState!.validate()) return;

    final min = double.parse(_minController.text);
    final max = double.parse(_maxController.text);

    AppDialog.show(
      context,
      title: 'Confirmar cambio',
      subtitle: '¿Confirmas cambiar el rango a $min–$max $unit?',
      confirmLabel: 'Confirmar',
      cancelLabel: 'Cancelar',
      onConfirm: () {
        Navigator.of(context).pop();
        _save(min, max);
      },
    );
  }

  Future<void> _save(double min, double max) async {
    final errorMessage = await ref
        .read(setpointEditControllerProvider(widget.sensorId).notifier)
        .save(min, max);

    if (!mounted) return;

    if (errorMessage == null) {
      Navigator.of(context).pop();
      AppSnackBar.show(
        context,
        type: SnackBarType.success,
        message: 'Setpoint actualizado.',
      );
    } else {
      AppSnackBar.show(context, type: SnackBarType.error, message: errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final asyncState = ref.watch(
      setpointEditControllerProvider(widget.sensorId),
    );

    final loadedState = asyncState.value;
    if (!_prefilled && loadedState != null) {
      _minController.text = loadedState.min.toString();
      _maxController.text = loadedState.max.toString();
      _prefilled = true;
    }

    return AppBottomSheet(
      title: 'Editar setpoint',
      confirmLabel: 'Guardar',
      isLoading: loadedState?.isSaving ?? false,
      onConfirm: loadedState == null
          ? null
          : () => _handleSavePressed(loadedState.setpoint.unit),
      content: asyncState.when(
        data: (state) => _buildForm(state),
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stackTrace) => AppText.body(
          'No pudimos cargar el setpoint.',
          color: colors.error,
        ),
      ),
    );
  }

  Widget _buildForm(SetpointEditState state) {
    final tokens = AppTokens.of(context);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInputText(
            label: 'Mínimo (${state.setpoint.unit})',
            textEditingController: _minController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: _numberValidator,
          ),
          SizedBox(height: tokens.spacing.smallMedium),
          AppInputText(
            label: 'Máximo (${state.setpoint.unit})',
            textEditingController: _maxController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            validator: _maxValidator,
          ),
        ],
      ),
    );
  }
}
