import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el modo de tema y lo persiste en SharedPreferences.
/// Claves:
///   themeMode: 'light' | 'dark' | 'system'
class ThemeProvider extends ChangeNotifier {
  static const _kPrefsKey = 'themeMode';
  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false; // para saber si ya se leyó de prefs

  ThemeProvider({ThemeMode? initial}) {
    if (initial != null) {
      _themeMode = initial;
      _loaded = true;
    } else {
      _load();
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = prefs.getString(_kPrefsKey);
      if (value != null) {
        switch (value) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            _themeMode = ThemeMode.system;
        }
      }
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (_themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system'
    };
    await prefs.setString(_kPrefsKey, value);
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : _themeMode == ThemeMode.dark
            ? ThemeMode.light
            : ThemeMode.dark; // si estaba en system, pasa a dark
    _persist();
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _persist();
    notifyListeners();
  }
}
