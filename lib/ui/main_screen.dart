import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/animated_navigator.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/pages/main_pages.dart';
import 'package:nasa_apod/ui/pages/get_app_web.dart';
import 'package:provider/provider.dart';
import 'package:nasa_apod/provider/main_screen_controller.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final controller = Provider.of<MainScreenController>(context, listen: false);
      controller.goTo(widget.initialIndex);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mainScreenController = Provider.of<MainScreenController>(context);
    final authService = AuthService();
    final pages = [
      MainPages.home(),
      MainPages.favorites(authService),
      MainPages.settings(authService),
  const GetAppWebPage(),
    ];
    void handleNavTap(int i) {
      if (i < 0 || i > 3) return; // tabs principales incluyendo get-app
      mainScreenController.goTo(i);
      final route = switch (i) {
        0 => '/home',
        1 => '/favorites',
        2 => '/settings',
        3 => '/get-app',
        _ => '/home',
      };
      // reemplazar para no apilar rutas
      Navigator.of(context).pushReplacementNamed(route);
    }
    return AnimatedNavigator(
      currentIndex: mainScreenController.index,
      pages: pages,
      onNavTap: handleNavTap,
      transition: mainScreenController.transition,
    );
  }
}
