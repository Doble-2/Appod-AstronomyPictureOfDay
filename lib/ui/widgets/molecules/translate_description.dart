import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nasa_apod/l10n/app_localizations.dart';

/// Traduce texto usando MyMemory API (gratis, CORS habilitado para web).
/// Reemplaza al paquete `translator`, cuyo endpoint de Google devolvía
/// 403 y era bloqueado por CORS en Flutter Web.
///
/// Las descripciones de NASA superan el límite de 500 caracteres por
/// query de MyMemory, así que el texto se divide en bloques de ~480
/// caracteres (en límites de oración), se traducen y se unen.
///
/// Límite diario gratuito de MyMemory: ~5000 caracteres por IP.
/// Para no agotarlo, se traducen como máximo los primeros ~2000
/// caracteres (la explicación; los créditos finales se descartan).
Future<String> translateDescription(
    BuildContext context, String description, AppLocalizations i10n) async {
  final locale = Localizations.localeOf(context);
  final toLang = locale.languageCode;

  // Ya está en el idioma de la app: no traducir.
  if (toLang == 'en') return description;

  final supported = {'es', 'fr', 'de', 'it', 'pt', 'ja', 'zh', 'ru', 'ar'};
  final target = supported.contains(toLang) ? toLang : 'es';

  const maxInput = 2000;
  const chunkSize = 480;
  final text = description.length <= maxInput
      ? description
      : description.substring(0, maxInput);

  final chunks = _splitInSentenceBoundaries(text, chunkSize);
  final buffer = StringBuffer();
  try {
    for (final chunk in chunks) {
      final uri = Uri.https(
        'api.mymemory.translated.net',
        '/get',
        {'q': chunk, 'langpair': 'en|$target'},
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) {
        // Si ya se tradujo algo, devolverlo; si no, error genérico.
        return buffer.isEmpty ? i10n.genericError : buffer.toString().trim();
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final quotaFinished = data['quotaFinished'] == true;
      final translated =
          ((data['responseData'] as Map<String, dynamic>?)?['translatedText'])
              as String?;
      if (translated != null && translated.isNotEmpty) {
        buffer.write(translated);
        buffer.write(' ');
      }
      if (quotaFinished) break;
    }
    final result = buffer.toString().trim();
    return result.isEmpty ? i10n.genericError : result;
  } catch (e) {
    return buffer.isEmpty ? i10n.genericError : buffer.toString().trim();
  }
}

/// Divide [text] en bloques de ~[maxLen] caracteres, cortando en los
/// límites de oración más cercanos (". ", "! ", "? ") cuando es posible.
List<String> _splitInSentenceBoundaries(String text, int maxLen) {
  if (text.length <= maxLen) return [text];
  final chunks = <String>[];
  var start = 0;
  while (start < text.length) {
    var end = (start + maxLen).clamp(0, text.length);
    if (end < text.length) {
      // Buscar el último límite de oración dentro del bloque.
      final window = text.substring(start, end);
      final lastBoundary = _lastSentenceBoundary(window);
      if (lastBoundary > maxLen ~/ 2) {
        end = start + lastBoundary + 1; // incluye el espacio
      }
    }
    chunks.add(text.substring(start, end).trim());
    start = end;
  }
  return chunks.where((c) => c.isNotEmpty).toList();
}

int _lastSentenceBoundary(String s) {
  var last = -1;
  for (final sep in ['. ', '! ', '? ', '.\n', '!\n', '?\n']) {
    final idx = s.lastIndexOf(sep);
    if (idx > last) last = idx + sep.length - 1;
  }
  return last;
}
