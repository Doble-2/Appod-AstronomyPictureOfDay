// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:nasa_apod/utils/image_proxy.dart';

/// Descarga en web: fetch de la imagen vía proxy CORS → blob → descarga
/// real con nombre de archivo. El atributo `download` de un anchor no
/// funciona con URLs cross-origin, por eso se usa un ObjectURL local.
Future<void> saveNetworkImage(BuildContext context, String imageUrl, String title) async {
  try {
    final url = apodImageUrl(imageUrl);
    final response = await html.HttpRequest.request(
      url,
      responseType: 'blob',
    );
    if (response.status != 200) {
      throw Exception('HTTP ${response.status}');
    }
    final blob = response.response as html.Blob?;
    if (blob == null) throw Exception('Sin datos');

    final sanitizedTitle = _sanitize(title);
    final objectUrl = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: objectUrl)
      ..download = '$sanitizedTitle.jpg'
      ..click();
    html.Url.revokeObjectUrl(objectUrl);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Descarga iniciada.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error iniciando descarga: $e')),
      );
    }
  }
}

String _sanitize(String input) => input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
