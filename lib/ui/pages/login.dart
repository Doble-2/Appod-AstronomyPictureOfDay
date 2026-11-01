import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/pages/auth_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return AuthForm(
      title: i10n.welcomeBack,
      submitLabel: i10n.login,
      switchLabel: i10n.notHaveAccount,
      passwordAutofill: const [AutofillHints.password],
      onSwitch: () => Navigator.pushNamed(context, AppRoutes.register),
      submit: (email, password) => AuthService().login(email: email, password: password),
    );
  }
}
