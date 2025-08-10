import 'package:flutter/material.dart';
import 'dart:html' as html;

Future<void> saveNetworkImage(BuildContext context, String imageUrl, String title) async {
  try {
    final sanitizedTitle = _sanitize(title);
    // Crear anchor para forzar descarga o abrir
    final anchor = html.AnchorElement(href: imageUrl)
      ..download = '$sanitizedTitle.jpg'
      ..target = '_blank';
    anchor.click();
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
