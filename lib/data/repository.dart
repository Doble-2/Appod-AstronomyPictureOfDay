import 'package:nasa_apod/data/firebase.dart';
import 'nasa.dart';
import 'package:nasa_apod/domain/contract.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Sencillo caché en memoria con TTL para reducir llamadas a la API de NASA.
class _ApodCache {
  final _singleDay = <String, Map<String, dynamic>>{}; // llave: yyyy-MM-dd
  final _fetchedAt = <String, DateTime>{};
  final Duration ttl = const Duration(minutes: 30);
  bool _loaded = false;
  static const _prefsKey = 'apod_cache_v1';

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          final items = decoded['items'];
            if (items is Map) {
              items.forEach((k, v) {
                if (v is Map) {
                  _singleDay[k] = Map<String, dynamic>.from(v);
                  final ts = v['__cachedAt'];
                  if (ts is String) {
                    _fetchedAt[k] = DateTime.tryParse(ts) ?? DateTime.now();
                  } else {
                    _fetchedAt[k] = DateTime.now();
                  }
                }
              });
            }
        }
      }
    } catch (_) {
      // Ignorar errores de deserialización.
    } finally {
      _loaded = true;
      _purgeExpired();
    }
  }

  void _purgeExpired() {
    final now = DateTime.now();
    final toRemove = <String>[];
    _fetchedAt.forEach((k, ts) {
      if (now.difference(ts) > ttl) toRemove.add(k);
    });
    for (final k in toRemove) {
      _fetchedAt.remove(k);
      _singleDay.remove(k);
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final map = <String, dynamic>{};
      _singleDay.forEach((k, v) {
        map[k] = {
          ...v,
          '__cachedAt': _fetchedAt[k]?.toIso8601String(),
        };
      });
      await prefs.setString(_prefsKey, jsonEncode({'items': map}));
    } catch (_) {}
  }

  Map<String, dynamic>? get(String date) {
    if (!_loaded) {
      // No se ha cargado todavía; retornamos null para forzar fetch.
    }
    final ts = _fetchedAt[date];
    if (ts == null) return null;
    if (DateTime.now().difference(ts) > ttl) {
      _singleDay.remove(date);
      _fetchedAt.remove(date);
      return null;
    }
    return _singleDay[date];
  }

  void put(String date, Map<String, dynamic> data) {
    _singleDay[date] = data;
    _fetchedAt[date] = DateTime.now();
  _persist();
  }
}

class ApodRepositoryImpl implements ApodRepository {
  final NetworkService _networkService;
  final _ApodCache _cache = _ApodCache();

  ApodRepositoryImpl(this._networkService);

  @override
  Future<Map<String, dynamic>?> getApod(String date) async {
  await _cache.ensureLoaded();
  // Caché primero
  final cached = _cache.get(date);
  if (cached != null) return cached;
  final data = await _networkService.getApod(date);
  _cache.put(date, data);
  return data;
  }

  @override
  Future<List> getMultipleApod(String date, {int count = 5}) async {
  await _cache.ensureLoaded();
    final DateFormat format = DateFormat('yyyy-MM-dd');
    DateTime target = format.parse(date);
  // Rango dinámico: 'count' días anteriores excluyendo el actual -> (date-count) .. (date-1)
  final DateTime start = target.subtract(Duration(days: count));
    final DateTime end = target.subtract(const Duration(days: 1));
    // Ajuste si rango cruza antes de 1995-06-16 (primer APOD)
    final earliest = DateTime(1995, 6, 16);
    final DateTime safeStart = start.isBefore(earliest) ? earliest : start;
    if (end.isBefore(earliest)) return [];

    // Intentar cubrir desde caché primero
    List<Map<String, dynamic>> collected = [];
    bool needNetwork = false;
    for (int i = 0; i <= end.difference(safeStart).inDays; i++) {
      final d = format.format(safeStart.add(Duration(days: i)));
      final cached = _cache.get(d);
      if (cached != null) {
        collected.add(cached);
      } else {
        needNetwork = true;
      }
    }

    if (needNetwork) {
      // Llamada única al endpoint de rango para minimizar latencia.
      // NASA APOD soporta start_date y end_date. Devuelve lista de objetos.
      final rangeData = await _networkService.getApodRange(safeStart, end);
      for (final item in rangeData) {
        final d = item['date'];
        if (d is String) {
          _cache.put(d, item as Map<String, dynamic>);
        }
      }
      // Reconstruir lista completa desde caché para mantener orden consistente.
      collected = [];
      for (int i = 0; i <= end.difference(safeStart).inDays; i++) {
        final d = format.format(safeStart.add(Duration(days: i)));
        final cached = _cache.get(d);
        if (cached != null) collected.add(cached);
      }
    }

    // Orden descendente (más reciente primero)
    collected.sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
    return collected;
  }

  // Método getApodRange eliminado

  @override
  Future<List> getFavoritesApod() async {
    List<Map<String, dynamic>> favoriteApodData = [];
    final List favoriteDates = await AuthService().getFavorites();
    for (int i = 0; i < favoriteDates.length; i++) {
      final String date = favoriteDates[i];
      // Aquí puedes agregar la lógica para obtener los datos de APOD para cada fecha
      final Map<String, dynamic> apodData = await _networkService.getApod(date);
      favoriteApodData.add(apodData);
    }
    favoriteApodData = favoriteApodData.reversed.toList();

    return favoriteApodData;
  }
}
