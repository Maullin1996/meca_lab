import 'package:atomic_design/design_system.dart';
import 'package:flutter/material.dart';

/// Desktop composition of the login screen: one framed panel split into a
/// live-telemetry preview and the form, instead of a mobile form stretched
/// across the window. Stateless with respect to Riverpod/fpdart — the only
/// local state is the form's own text controllers and the
/// password-visibility toggle.
class LoginWebView extends StatefulWidget {
  final void Function(String email, String password) onSubmit;
  final bool isLoading;
  final String? errorMessage;

  const LoginWebView({
    super.key,
    required this.onSubmit,
    required this.isLoading,
    this.errorMessage,
  });

  @override
  State<LoginWebView> createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040, maxHeight: 640),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacing.mediumLarge),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(tokens.radius.large),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceHigh,
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _TelemetryPanel(colors: colors, tokens: tokens),
                    ),
                    VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: colors.divider,
                    ),
                    Expanded(
                      flex: 4,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.all(tokens.spacing.large),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppText.h3(
                                  'Ingresa a tu cuenta',
                                  color: colors.textPrimary,
                                ),
                                SizedBox(height: tokens.spacing.xSmall),
                                AppText.label(
                                  'Usa las credenciales que te asignó tu administrador.',
                                  color: colors.textSecondary,
                                ),
                                SizedBox(height: tokens.spacing.medium),
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
                                  fillColor: colors.border,
                                  textEditingController: _passwordController,
                                  obscureText: _obscure,
                                  prefixIcon: Icon(AppIcons.obscurePassword),
                                  suffixIcon: AppButtons(
                                    type: ButtonType.primaryIconButton,
                                    icon: _obscure
                                        ? AppIcons.showPassword
                                        : AppIcons.obscurePassword,
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                  validator: _requiredValidator,
                                ),
                                if (widget.errorMessage != null) ...[
                                  SizedBox(height: tokens.spacing.small),
                                  AppText.label(
                                    widget.errorMessage!,
                                    color: colors.error,
                                  ),
                                ],
                                SizedBox(height: tokens.spacing.large),
                                AppButtons(
                                  type: ButtonType.primaryFillButton,
                                  isLoading: widget.isLoading,
                                  onPressed: _submit,
                                  title: AppText.h4(
                                    'Ingresar',
                                    color: colors.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

/// The signature element: a live-looking readout of plant telemetry,
/// recessed like an instrument screen. Previews the real thing the product
/// does (device/sensor monitoring) instead of decorating the panel with
/// unrelated hero copy. Device names are fictional demo data.
class _TelemetryPanel extends StatelessWidget {
  final AppColors colors;
  final AppTokens tokens;

  const _TelemetryPanel({required this.colors, required this.tokens});

  static const _readings = [
    (id: 'COMP-04', metric: '78.2 °C', label: 'online', dot: _Dot.online),
    (id: 'BAND-02', metric: '0.4 mm/s', label: 'warning', dot: _Dot.warning),
    (id: 'BOMBA-01', metric: '4.1 bar', label: 'critical', dot: _Dot.critical),
    (id: 'MOTOR-03', metric: '—', label: 'offline', dot: _Dot.offline),
  ];

  Color _dotColor(_Dot dot) {
    return switch (dot) {
      _Dot.online => colors.success,
      _Dot.warning => colors.warning,
      _Dot.critical => colors.error,
      _Dot.offline => colors.textDisabled,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.surfaceLow,
      child: Padding(
        padding: EdgeInsets.all(tokens.spacing.mediumLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PLANT MONITOR',
                  style: TextStyle(
                    // atomic_design's AppTypographyTokens doesn't expose
                    // fontFamilyMono even though the JSON config defines it
                    // (only `fontFamily` is read in fromConfig) — literal
                    // used until that's fixed upstream.
                    fontFamily: 'JetBrains Mono',
                    fontSize: tokens.typography.caption,
                    letterSpacing: 2,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: tokens.spacing.small),
                AppText.h1('MecLab', color: colors.primary),
                SizedBox(height: tokens.spacing.xSmall),
                AppText.bodyLg(
                  'Monitoreo industrial en tiempo real.',
                  color: colors.textSecondary,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final reading in _readings) ...[
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _dotColor(reading.dot),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: tokens.spacing.small),
                      Expanded(
                        child: Text(
                          reading.id,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: tokens.typography.body,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        reading.metric,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: tokens.typography.body,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: tokens.spacing.small),
                ],
              ],
            ),
            AppText.caption(
              'Datos simulados — ambiente de demostración.',
              color: colors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

enum _Dot { online, warning, critical, offline }
