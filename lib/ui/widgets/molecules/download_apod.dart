// image_saver.dart
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

void saveNetworkImage(String imageUrl, String title) async {
  Fluttertoast.showToast(
      msg: "Procesando la solicitud, por favor espere...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0);
  var response = await Dio()
      .get(imageUrl, options: Options(responseType: ResponseType.bytes));
  // await ImageGallerySaver.saveImage(Uint8List.fromList(response.data),
  //     name: title);
  Fluttertoast.showToast(
      msg: "Operación completada con éxito.",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      fontSize: 16.0);
}
