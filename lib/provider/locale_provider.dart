import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
    Locale _selectedLanguage = const Locale('en', '');

    Locale get selectedLanguage => _selectedLanguage;

    void setLocale(Locale locale) {
      _selectedLanguage = locale;
      notifyListeners();
    }
  }