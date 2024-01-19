//t: este archivo contiene la clase NetworkService, que usa el patrón singleton para crear y acceder a una instancia del cliente http. Esta clase usa el paquete http para realizar las peticiones a la API y el paquete dio para manejar las excepciones y los errores.
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String nasaEndpoint = 'api.nasa.gov';
  static String? nasaKey = dotenv.env['nasaKey'];
  static String keyParameter = 'api_key';
  static String dateParameter = 'date';
}

class NetworkService {
  Future<Map<String, dynamic>> getApod(String date) async {
    print(ApiConstants.nasaKey);
    final queryParameters = {
      ApiConstants.keyParameter: ApiConstants.nasaKey,
      ApiConstants.dateParameter: date,
    };
    var url = Uri.https(
        ApiConstants.nasaEndpoint, '/planetary/apod', queryParameters);
    print(queryParameters);
    print(url);
    final response = await http.get(
      url,
      headers: {
        HttpHeaders.accessControlAllowOriginHeader: "*",
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.acceptHeader: '*/*',
      },
    );

    var responseData = jsonDecode(response.body);
    return responseData;
  }
}
