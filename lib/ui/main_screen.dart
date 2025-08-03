import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/organisms/animated_navigator.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/pages/main_pages.dart';
import 'package:provider/provider.dart';
import 'package:nasa_apod/provider/main_screen_controller.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mainScreenController = Provider.of<MainScreenController>(context);
    final authService = AuthService();
    final pages = [
      MainPages.home(),
      MainPages.favorites(authService),
      MainPages.settings(authService),
      MainPages.apod(),
    ];
    return AnimatedNavigator(
      currentIndex: mainScreenController.index,
      pages: pages,
      onNavTap: (i) => mainScreenController.goTo(i),
      transition: mainScreenController.transition,
    );
  }
}
