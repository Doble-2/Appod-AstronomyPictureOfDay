import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

Future<void> saveNetworkImage(BuildContext context, String imageUrl, String title) async {
  try {
    bool granted = true;
    if (Platform.isAndroid) {
      granted = await _requestAndroidPermissions();
    }
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado para guardar en galería.')),
        );
      }
      return;
    }

    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode != 200) {
      throw Exception('Respuesta HTTP ${response.statusCode}');
    }
    final sanitizedTitle = _sanitize(title);
    final result = await ImageGallerySaverPlus.saveImage(
      response.bodyBytes,
      name: 'appod/$sanitizedTitle',
      quality: 100,
    );
    if (context.mounted) {
      if (result['isSuccess'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Imagen guardada en la galería.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo guardar la imagen.')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    }
  }
}

Future<bool> _requestAndroidPermissions() async {
  if (await Permission.photos.isGranted || await Permission.storage.isGranted) {
    return true;
  }
  if (await Permission.photos.request().isGranted) return true;
  if (await Permission.storage.request().isGranted) return true;
  return false;
}

String _sanitize(String input) => input.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
