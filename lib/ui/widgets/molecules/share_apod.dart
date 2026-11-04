import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nasa_apod/ui/widgets/common.dart';
import 'package:flutter/services.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// Comparte el APOD con un mensaje limpio y personal, sin enlaces externos.
///
/// El enlace es el de nuestra app (`/apod/YYYY-MM-DD`). Las redes muestran la
/// tarjeta general de web/index.html, no la imagen de ese día.
///
/// En web sin Web Share API (Chrome desktop) hace fallback al portapapeles.
Future<void> shareApod(
  BuildContext context, {
  required String title,
  required String date,
  required String imageUrl,
  String? credit,
}) async {
  final appUrl = _appUrl(date);
  final i10n = AppLocalizations.of(context)!;
  final text = [
    i10n.shareText(date, appUrl),
    if (credit != null && credit.trim().isNotEmpty) '${i10n.imageCredit}: ${credit.trim()}',
  ].join('\n');

  // Capturar antes del await para evitar usar context tras un async gap.
  final toast = Toaster.of(context);

  try {
    await Share.share(text, subject: 'Appod · $title');
  } catch (e) {
    // Fallback: la Web Share API no está disponible → portapapeles.
    try {
      await Clipboard.setData(ClipboardData(text: text));
      toast.show(i10n.shareCopied, icon: Icons.link_rounded);
    } catch (_) {
toast.show('${i10n.shareFailed} $appUrl', icon: Icons.error_outline_rounded, tone: ToastTone.error);
    }
  }
}

/// URL de la app para una fecha. En nativo no hay dirección propia, así que
/// cae al APOD de NASA.
String _appUrl(String date) {
  if (kIsWeb) {
    final base = Uri.base;
    final url = base.replace(path: '/apod/$date', fragment: '');
    // Limpiar cualquier '#' residual del fragment vacío.
    return url.toString().replaceAll('#', '');
  }
  return 'https://apod.nasa.gov/apod/ap${_nasaShortDate(date)}.html';
}

/// Fecha corta estilo NASA: '2026-08-02' → '260802' (ap260802.html).
String _nasaShortDate(String date) {
  final parts = date.split('-');
  if (parts.length != 3) return date.replaceAll('-', '');
  return '${parts[0].substring(2)}${parts[1]}${parts[2]}';
}
