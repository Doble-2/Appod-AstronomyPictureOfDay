// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:translator/translator.dart';

 Future<String>translateDescription(BuildContext context, String description, AppLocalizations i10n) async {
  Locale locale = Localizations.localeOf(context);
  try {
    final translator = GoogleTranslator();
    final translated = await translator.translate(description, to: "es");
    if (context.mounted) {
      
      }
    return translated.text;
   
  } catch (e) {
    if (context.mounted) {
     return i10n.genericError;
    }
  }
  return description;
}

