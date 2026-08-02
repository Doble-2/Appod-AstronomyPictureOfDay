import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona la localización seleccionada y la persiste.
/// Claves:
///   localeCode: ej 'en' | 'es'
class LocaleProvider extends ChangeNotifier {
  static const _kPrefsKey = 'localeCode';
  Locale _selectedLanguage;

  LocaleProvider({Locale? initial})
      : _selectedLanguage = initial ?? const Locale('en');

  Locale get selectedLanguage => _selectedLanguage;

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
