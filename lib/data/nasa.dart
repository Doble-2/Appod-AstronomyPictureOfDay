//t: este archivo contiene la clase NetworkService, que usa el patrón singleton para crear y acceder a una instancia del cliente http. Esta clase usa el paquete http para realizar las peticiones a la API y el paquete dio para manejar las excepciones y los errores.
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// dotenv eliminado: se usarán constantes en tiempo de compilación via --dart-define

class ApiConstants {
  static String nasaEndpoint = 'api.nasa.gov';
  static const String nasaKey = String.fromEnvironment('NASA_KEY', defaultValue: 'DEMO_KEY');
  static const String imageProxyBaseUrl = String.fromEnvironment('IMAGE_PROXY_BASE_URL', defaultValue: '');
  static String keyParameter = 'api_key';
  static String dateParameter = 'date';
}

class NetworkService {
  Future<Map<String, dynamic>> getApod(String date) async {
    final queryParameters = {
      ApiConstants.keyParameter: ApiConstants.nasaKey,
      ApiConstants.dateParameter: date,
    };
    var url = Uri.https(
        ApiConstants.nasaEndpoint, '/planetary/apod', queryParameters);
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

  Future<List<dynamic>> getApodRange(DateTime start, DateTime end) async {
    final queryParameters = {
      ApiConstants.keyParameter: ApiConstants.nasaKey,
      'start_date': start.toIso8601String().split('T').first,
      'end_date': end.toIso8601String().split('T').first,
    };
    final url = Uri.https(ApiConstants.nasaEndpoint, '/planetary/apod', queryParameters);
    final response = await http.get(url, headers: {
      HttpHeaders.accessControlAllowOriginHeader: '*',
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: '*/*',
    });
    final body = jsonDecode(response.body);
    if (body is List) return body;
    // Si la API retornó un objeto (error), devolvemos lista vacía para no romper UI.
    return [];
  }
}
