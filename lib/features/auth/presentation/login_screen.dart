import 'package:absensi_dashboard/features/settings/presentation/settings_notifier.dart';
import 'package:absensi_dashboard/l10n/gen/app_localizations.dart';
import 'package:absensi_dashboard/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Admin login (UI only). Validates locally, then flips [authProvider].
final class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

final class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final ValueNotifier<bool> _valid = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _valid.dispose();
    super.dispose();
  }

  void _revalidate() {
    _valid.value = _formKey.currentState?.validate() ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations strings = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
              children: <Widget>[
                Text(strings.loginTitle, style: text.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.loginSubtitle,
                  style: text.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Form(
                  key: _formKey,
                  onChanged: _revalidate,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _email,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                        decoration: InputDecoration(
                          labelText: strings.loginEmail,
                          prefixIcon: const Icon(Icons.mail_rounded),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return strings.requiredField;
                          }
                          if (!RegExp(
                            r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                          ).hasMatch(value.trim())) {
                            return strings.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextFormField(
                        controller: _password,
                        focusNode: _passwordFocus,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          labelText: strings.loginPassword,
                          prefixIcon: const Icon(Icons.lock_rounded),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return strings.requiredField;
                          }
                          if (value.length < 6) {
                            return strings.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  strings.loginHint,
                  style: text.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ValueListenableBuilder<bool>(
                  valueListenable: _valid,
                  builder: (BuildContext context, bool valid, Widget? child) {
                    return Semantics(
                      button: true,
                      label: strings.loginButton,
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: valid
                              ? () {
                                  ref
                                      .read(authProvider.notifier)
                                      .login('Rina Wijaya');
                                  context.go('/home');
                                }
                              : null,
                          child: Text(strings.loginButton),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
