import 'package:flutter/material.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:provider/provider.dart';

import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
      ]),
    );
  }
}
