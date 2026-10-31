import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/pages/favorites.dart';
import 'package:nasa_apod/ui/pages/get_app_web.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/ui/pages/settings.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

class MainScreen extends StatelessWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  static const _routes = ['/home', '/favorites', '/settings', '/get-app'];

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Layout(
      currentIndex: initialIndex,
      // Each tab has its own route, so the web address always matches the screen.
      onTap: (i) {
        if (i != initialIndex) Navigator.of(context).pushReplacementNamed(_routes[i]);
      },
      child: switch (initialIndex) {
        1 => FavoritesView(authService: authService),
        2 => SettingsView(authService: authService),
        3 => const GetAppWebPage(),
        _ => const HomeView(),
      },
    );
  }
}
