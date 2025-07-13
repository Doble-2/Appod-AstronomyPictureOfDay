// image_saver.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

void saveNetworkImage(BuildContext context, String imageUrl, String title) async {
  try {
    // Descargar imagen
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final dir = await getTemporaryDirectory();
    var filename = '${dir.path}/${title.replaceAll(' ', '')}.png';
    final file = File(filename);
    await file.writeAsBytes(response.bodyBytes);
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final finalPath = await FlutterFileDialog.saveFile(params: params);
    if (finalPath != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen guardada con éxito.')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar la imagen: $e')),
      );
    }
  }
}
