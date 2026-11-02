import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/ui/pages/auth_form.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    return AuthForm(
      title: i10n.createAccount,
      submitLabel: i10n.register,
      switchLabel: i10n.yetHaveAccount,
      minPasswordLength: 6,
      passwordAutofill: const [AutofillHints.newPassword],
      onSwitch: () => Navigator.pop(context),
      submit: (email, password) => AuthService().registration(email: email, password: password),
    );
  }
}
