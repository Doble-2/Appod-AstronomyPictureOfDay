import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

/// The login and register screens share everything except their wording.
class AuthForm extends StatefulWidget {
  final String title;
  final String submitLabel;
  final String switchLabel;
  final VoidCallback onSwitch;
  final int minPasswordLength;
  final Iterable<String> passwordAutofill;
  final Future<String?> Function(String email, String password) submit;

  const AuthForm({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.switchLabel,
    required this.onSwitch,
    required this.submit,
    required this.passwordAutofill,
    this.minPasswordLength = 1,
  });

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final scheme = Theme.of(context).colorScheme;
    final message = await widget.submit(_email.text.trim(), _password.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (message != null && message.contains('Success')) {
      navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } else {
      messenger.showSnackBar(SnackBar(content: Text(message ?? ''), backgroundColor: scheme.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final i10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, bottom: 48),
        child: PageBody(
          maxWidth: 440,
          child: Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(alignment: Alignment.centerLeft, child: AppodLogo()),
                  const SizedBox(height: 32),
                  Text(widget.title, style: theme.textTheme.displaySmall),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _email,
                    decoration: InputDecoration(labelText: i10n.email),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return i10n.pleaseInterEmail;
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) return i10n.pleaseInterValidEmail;
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: i10n.password,
                      suffixIcon: IconButton(
                        tooltip: i10n.showPassword,
                        icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    autofillHints: widget.passwordAutofill,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      if (value == null || value.isEmpty) return i10n.pleaseInterPassword;
                      if (value.length < widget.minPasswordLength) return i10n.digitsPass;
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(widget.submitLabel),
                  ),
                  const SizedBox(height: 8),
                  TextButton(onPressed: widget.onSwitch, child: Text(widget.switchLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
