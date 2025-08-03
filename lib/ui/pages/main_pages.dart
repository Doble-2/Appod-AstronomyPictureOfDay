import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'favorites.dart';
import 'home.dart';
import 'settings.dart';

class MainPages {
  static Widget home() => const HomeView();
  static Widget favorites(AuthService authService) => FavoritesView(authService: authService);
  static Widget settings(AuthService authService) => SettingsView(authService: authService);
  static Widget apod() => const ApodView();
}
