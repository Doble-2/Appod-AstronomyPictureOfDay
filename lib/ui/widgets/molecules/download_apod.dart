// image_saver.dart
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void saveNetworkImage(String imageUrl, String title) async {
  Fluttertoast.showToast(
      msg: "Procesando la solicitud, por favor espere...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0);
  var response = await Dio()
      .get(imageUrl, options: Options(responseType: ResponseType.bytes));
  final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      name: title);
  print(result);
  Fluttertoast.showToast(
      msg: "Operación completada con éxito.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0);
}
