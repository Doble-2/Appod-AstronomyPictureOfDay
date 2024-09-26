import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/provider/theme_provider.dart';

import 'package:nasa_apod/ui/widgets/organisms/layout.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  final AuthService authService;

  const SettingsView({super.key, required this.authService});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  void handleLogout() async {
    await widget.authService.logout();
    // Clear user data from SharedPreferences (optional)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userUID');

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(children: [
        SwitchListTile(
          title: const Text('Dark Mode'),
          value: context.watch<ThemeProvider>().themeMode == ThemeMode.dark,
          onChanged: (value) {
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        ),
        ElevatedButton(
          onPressed: handleLogout,
          child: const Text('Logout'),
        ),
      ]),
    );
  }
}
