import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Every day read from NASA, kept across launches. A day's picture never
/// changes, so entries don't expire; the least recently used ones make way
/// once there are [maxDays], which keeps within the web's storage limit.
class ApodCache {
  ApodCache._();
  static final instance = ApodCache._();

  static const maxDays = 400;
  static const _key = 'apod_cache_v2'; // v1 held pictures at their full, heavy size.
  static const _saveDelay = Duration(milliseconds: 500);

  // Dart maps keep insertion order, which here is order of use.
  final _days = <String, Map<String, dynamic>>{};
  final _missing = <String>{};
  Future<void>? _loading;
  Timer? _saveTimer;

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('apod_cache_v1');
      final raw = prefs.getString(_key);
      if (raw == null) return;
      (jsonDecode(raw) as Map<String, dynamic>).forEach((date, day) {
        _days[date] = Map<String, dynamic>.from(day as Map);
      });
    } catch (_) {
      // A damaged cache only costs a new download.
    }
  }

  Map<String, dynamic>? get(String date) {
    final day = _days.remove(date);
    if (day != null) _days[date] = day; // Now the most recently used.
    return day;
  }

  void put(String date, Map<String, dynamic> day) {
    _days.remove(date);
    _days[date] = day;
    _missing.remove(date);
    while (_days.length > maxDays) {
      _days.remove(_days.keys.first);
    }
    // Many days arrive together, so they are saved together.
    _saveTimer?.cancel();
    _saveTimer = Timer(_saveDelay, save);
  }

  /// The newest saved day, to show when NASA can't be reached.
  String? get latestDate => _days.isEmpty ? null : _days.keys.reduce((a, b) => a.compareTo(b) > 0 ? a : b);

  /// Past days with no article, remembered until the app closes to save lookups.
  bool isMissing(String date) => _missing.contains(date);
  void markMissing(String date) => _missing.add(date);

  Future<void> save() async {
    _saveTimer?.cancel();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(_days));
    } catch (_) {
      // Storage full or blocked: the app keeps working from memory.
    }
  }

  void clearForTest() {
    _days.clear();
    _missing.clear();
    _loading = null;
    _saveTimer?.cancel();
  }
}
