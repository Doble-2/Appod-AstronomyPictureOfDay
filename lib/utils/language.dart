import 'dart:ui';

enum Language { english, spanish }

extension LanguageExtension on Language {
  String get locale {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.spanish:
        return 'es';
      }
  }

  String get name {
    switch (this) {
      case Language.english:
        return 'English';
      case Language.spanish:
        return 'Español';
      }
  }

  String get flag {
    switch (this) {
      case Language.english:
        return '🇺🇸';
      case Language.spanish:
        return '🇪🇸';
      }
  }

  Locale get localeValue {
    switch (this) {
      case Language.english:
        return const Locale('en');
      case Language.spanish:
        return const Locale('es');
      }
  }
}