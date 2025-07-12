// image_saver.dart
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

void saveNetworkImage(String imageUrl, String title) async {
  try {
    // Download image
    final http.Response response = await http.get(Uri.parse(imageUrl));

    // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    var filename = '${dir.path}/${title.replaceAll(' ', '')}.png';

    // Save to filesystem
    final file = File(filename);
    await file.writeAsBytes(response.bodyBytes);

    // Ask the user to save it
    final params = SaveFileDialogParams(sourceFilePath: file.path);
    final finalPath = await FlutterFileDialog.saveFile(params: params);

    if (finalPath != null) {
      // Operación completada con éxito.
    }
  } catch (e) {
    // No pudimos instalar la imagen
  }
}
