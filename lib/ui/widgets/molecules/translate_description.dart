import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:translator/translator.dart';

Future<String> translateDescription(
    BuildContext context, String description, AppLocalizations i10n) async {
  final locale = Localizations.localeOf(context);
  try {
    final translator = GoogleTranslator();
    final translated = await translator.translate(description, to: locale.languageCode);
    return translated.text;
  } catch (e) {
    return i10n.genericError;
  }
}
