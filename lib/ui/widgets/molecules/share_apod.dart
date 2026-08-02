import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// Comparte el APOD con un mensaje limpio y personal, sin enlaces externos.
///
/// El enlace es el de nuestra app (`/apod/YYYY-MM-DD`): el servidor
/// (server_og.py) devuelve metadata OG dinámica a los crawlers de
/// WhatsApp/Telegram, así la preview sale con la imagen del día.
///
/// En web sin Web Share API (Chrome desktop) hace fallback al portapapeles.
Future<void> shareApod(
  BuildContext context, {
  required String title,
  required String date,
  required String imageUrl,
}) async {
  final appUrl = _appUrl(date);
  final text = 'Hola, mira la foto astronómica del día $date: $appUrl';

  // Capturar antes del await para evitar usar context tras un async gap.
  final messenger = ScaffoldMessenger.of(context);
  final scheme = Theme.of(context).colorScheme;

  try {
    await Share.share(text, subject: 'Appod · $title');
  } catch (e) {
    // Fallback: la Web Share API no está disponible → portapapeles.
    try {
      await Clipboard.setData(ClipboardData(text: text));
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: scheme.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                  child: Text('Mensaje copiado, pégalo donde quieras')),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('No se pudo compartir. Enlace: $appUrl')),
      );
    }
  }
}

/// URL de la app para una fecha: usa la ruta `/apod/YYYY-MM-DD` (sin hash)
/// para que los crawlers reciban el HTML con og:image dinámico servido por
/// server_og.py. En nativo (sin servidor propio) cae al APOD de NASA.
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
