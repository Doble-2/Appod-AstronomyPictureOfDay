import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la localización seleccionada y la persiste.
/// Claves:
///   localeCode: ej 'en' | 'es'
class LocaleProvider extends ChangeNotifier {
  static const _kPrefsKey = 'localeCode';
  Locale _selectedLanguage = const Locale('en');
  bool _loaded = false;

  LocaleProvider({Locale? initial}) {
    if (initial != null) {
      _selectedLanguage = initial;
      _loaded = true;
    } else {
      _load();
    }
  }

  Locale get selectedLanguage => _selectedLanguage;
  bool get isLoaded => _loaded;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_kPrefsKey);
      if (code != null && code.isNotEmpty) {
        _selectedLanguage = Locale(code);
      }
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, _selectedLanguage.languageCode);
  }

  void setLocale(Locale locale) {
    _selectedLanguage = locale;
    _persist();
    notifyListeners();
  }
}