import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:nasa_apod/ui/widgets/organisms/layout.dart';

import 'package:nasa_apod/provider/main_screen_controller.dart';

class AnimatedNavigator extends StatelessWidget {
  final int currentIndex;
  final List<Widget> pages;
  final void Function(int) onNavTap;
  final MainScreenTransition transition;

  const AnimatedNavigator({
    super.key,
    required this.currentIndex,
    required this.pages,
    required this.onNavTap,
    this.transition = MainScreenTransition.fade,
  });

  @override
  Widget build(BuildContext context) {
    Widget transitionBuilder(child, Animation<double> animation, Animation<double> secondaryAnimation) {
      switch (transition) {
        case MainScreenTransition.fade:
          return FadeThroughTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            child: child,
          );
        case MainScreenTransition.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        case MainScreenTransition.scale:
          return ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
            child: child,
          );
      }
    }
    return PageTransitionSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: transitionBuilder,
      child: KeyedSubtree(
        key: ValueKey(currentIndex),
        child: Layout(
          currentIndex: currentIndex,
          onNavTap: onNavTap,
          child: pages[currentIndex],
        ),
      ),
    );
  }
}
