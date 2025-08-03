import 'package:flutter/material.dart';

enum MainScreenTransition { fade, slide, scale }

class MainScreenController extends ChangeNotifier {
  int _index = 0;
  MainScreenTransition _transition = MainScreenTransition.fade;

  int get index => _index;
  MainScreenTransition get transition => _transition;

  void goTo(int newIndex, {MainScreenTransition? animation}) {
    _index = newIndex;
    if (animation != null) _transition = animation;
    notifyListeners();
  }
}
