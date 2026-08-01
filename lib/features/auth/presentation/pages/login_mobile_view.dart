import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// Mobile composition of the login screen. Stateless with respect to
/// Riverpod/fpdart — the only local state is the form's own text
/// controllers and the password-visibility toggle.
class LoginMobileView extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const LoginMobileView({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  State<LoginMobileView> createState() => _LoginMobileViewState();
}

class _LoginMobileViewState extends State<LoginMobileView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El campo no puede estar vacío';
    }
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_emailController.text.trim(), _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final tokens = AppTokens.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.spacing.medium),
            child: AppCard(
              padding: EdgeInsets.all(tokens.spacing.smallMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText.h4('MecLab IoT', color: colors.textPrimary),
                    SizedBox(height: tokens.spacing.smallMedium),
                    AppInputText(
                      label: 'Email',
                      fillColor: colors.border,
                      textEditingController: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(AppIcons.user),
                      validator: _requiredValidator,
                    ),
                    SizedBox(height: tokens.spacing.smallMedium),
                    AppInputText(
                      label: 'Contraseña',
                      textEditingController: _passwordController,
                      fillColor: colors.border,
                      obscureText: _obscure,
                      prefixIcon: Icon(AppIcons.obscurePassword),
                      suffixIcon: AppButtons(
                        type: ButtonType.primaryIconButton,
                        icon: _obscure
                            ? AppIcons.showPassword
                            : AppIcons.obscurePassword,
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      validator: _requiredValidator,
                    ),
                    if (widget.errorMessage != null) ...[
                      SizedBox(height: tokens.spacing.small),
                      AppText.label(widget.errorMessage!, color: colors.error),
                    ],
                    SizedBox(height: tokens.spacing.large),
                    AppButtons(
                      type: ButtonType.primaryFillButton,
                      isLoading: widget.isLoading,
                      onPressed: _submit,
                      title: AppText.h4('Ingresar', color: colors.onPrimary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
