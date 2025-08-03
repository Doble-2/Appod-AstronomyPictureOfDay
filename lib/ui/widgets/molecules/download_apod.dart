
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart'; // NEW
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

void saveNetworkImage(BuildContext context, String imageUrl, String title) async {
  try {
    // Solicitar permisos según versión de Android
    bool granted = false;
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted || await Permission.photos.isGranted) {
        granted = true;
      } else {
        if (await Permission.photos.request().isGranted) {
          granted = true;
        } else if (await Permission.storage.request().isGranted) {
          granted = true;
        }
      }
    } else {
      granted = true; // iOS y otros
    }
    if (!granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso denegado para guardar en galería.')),
        );
      }
      return;
    }
    // Descargar imagen
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final sanitizedTitle = title.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
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
          const SnackBar(content: Text('No se pudo guardar la imagen en la galería.')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la imagen: $e')),
      );
    }
  }
}
