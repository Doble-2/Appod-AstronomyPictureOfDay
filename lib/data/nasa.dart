//t: este archivo contiene la clase NetworkService, que usa el patrón singleton para crear y acceder a una instancia del cliente http. Esta clase usa el paquete http para realizar las peticiones a la API y el paquete dio para manejar las excepciones y los errores.
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:nasa_apod/data/apod_cache.dart';
import 'package:nasa_apod/data/nasa_site.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
// dotenv eliminado: se usarán constantes en tiempo de compilación via --dart-define

class ApiConstants {
  static String nasaEndpoint = 'api.nasa.gov';
  static const String nasaKey = String.fromEnvironment('NASA_KEY', defaultValue: 'DEMO_KEY');
  static const String imageProxyBaseUrl = String.fromEnvironment('IMAGE_PROXY_BASE_URL', defaultValue: '');
  static String keyParameter = 'api_key';
  static String dateParameter = 'date';
}

class NasaApiException implements Exception {
  final int? statusCode;
  final String? body;
  final String? message;
  const NasaApiException({this.statusCode, this.body, this.message});

  @override
  String toString() =>
  'NasaApiException(statusCode: ${statusCode?.toString() ?? 'null'}, message: ${message ?? ''})';
}

class NetworkService {
  final _site = NasaSiteSource();

  /// The official API now answers with this placeholder instead of the picture.
  static bool _isPlaceholder(Map item) =>
      item['title'] == 'NASA Science' || '${item['url']}'.contains('nasa-logo');

  /// A day from the cache, or from NASA, which then fills the cache.
  Future<Map<String, dynamic>> getApod(String date) async {
    final cache = ApodCache.instance;
    await cache.ensureLoaded();
    final cached = cache.get(date);
    if (cached != null) return cached;
    if (cache.isMissing(date)) throw NasaApiException(statusCode: 404, message: 'No APOD for $date');
    final day = await _fetchDay(date);
    cache.put(date, day);
    return day;
  }

  Future<Map<String, dynamic>> _fetchDay(String date) async {
    try {
      return await _site.getDay(date);
    } on NasaApiException catch (error) {
      // No article is a real answer. Otherwise try the API, if it works again.
      if (error.statusCode == 404) {
        // Today's picture may simply not be out yet, so only past days are remembered.
        if (date.compareTo(todayIso()) < 0) ApodCache.instance.markMissing(date);
        rethrow;
      }
      final fromApi = await _getApiDay(date);
      if (_isPlaceholder(fromApi)) rethrow;
      return fromApi;
    }
  }

  /// A stretch of days from NASA, all of which join the cache.
  Future<List<dynamic>> getApodRange(DateTime start, DateTime end) async {
    final cache = ApodCache.instance;
    await cache.ensureLoaded();
    final days = await _fetchRange(start, end);
    for (final day in days) {
      if (day is Map<String, dynamic> && day['date'] is String) cache.put(day['date'] as String, day);
    }
    return days;
  }

  Future<List<dynamic>> _fetchRange(DateTime start, DateTime end) async {
    try {
      return await _site.getRange(start, end);
    } on NasaApiException {
      final fromApi = await _getApiRange(start, end);
      if (fromApi.any((item) => item is Map && _isPlaceholder(item))) rethrow;
      return fromApi;
    }
  }

  Future<Map<String, dynamic>> _getApiDay(String date) async {
    final queryParameters = {
      ApiConstants.keyParameter: ApiConstants.nasaKey,
      ApiConstants.dateParameter: date,
    };
    var url = Uri.https(
        ApiConstants.nasaEndpoint, '/planetary/apod', queryParameters);
    try {
      final response = await http
          .get(
            url,
            headers: {
              HttpHeaders.accessControlAllowOriginHeader: "*",
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.acceptHeader: '*/*',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw NasaApiException(
          statusCode: response.statusCode,
          body: response.body,
          message: 'HTTP ${response.statusCode}',
        );
      }
      final responseData = jsonDecode(response.body);
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw const NasaApiException(message: 'Unexpected response shape');
    } on TimeoutException {
      throw const NasaApiException(statusCode: 504, message: 'Gateway Timeout');
    } on SocketException catch (e) {
      // Tratar errores de red como 504 para UX consistente
      throw NasaApiException(statusCode: 504, message: e.message);
    }
  }

  Future<List<dynamic>> _getApiRange(DateTime start, DateTime end) async {
    final queryParameters = {
      ApiConstants.keyParameter: ApiConstants.nasaKey,
      'start_date': start.toIso8601String().split('T').first,
      'end_date': end.toIso8601String().split('T').first,
    };
    final url = Uri.https(ApiConstants.nasaEndpoint, '/planetary/apod', queryParameters);
    try {
      final response = await http
          .get(url, headers: {
            HttpHeaders.accessControlAllowOriginHeader: '*',
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.acceptHeader: '*/*',
          })
          .timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw NasaApiException(
          statusCode: response.statusCode,
          body: response.body,
          message: 'HTTP ${response.statusCode}',
        );
      }
      final body = jsonDecode(response.body);
      if (body is List) return body;
      // Si la API retornó un objeto (error), devolvemos lista vacía para no romper UI.
      return [];
    } on TimeoutException {
      throw const NasaApiException(statusCode: 504, message: 'Gateway Timeout');
    } on SocketException catch (e) {
      throw NasaApiException(statusCode: 504, message: e.message);
    }
  }
}
