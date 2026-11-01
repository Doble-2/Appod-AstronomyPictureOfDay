import 'package:intl/intl.dart';
import 'package:nasa_apod/data/apod_cache.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/utils/apod_dates.dart';

import 'nasa.dart';

class ApodRepositoryImpl {
  final NetworkService _networkService;

  ApodRepositoryImpl(this._networkService);

  Future<Map<String, dynamic>?> getApod(String date) => _networkService.getApod(date);

  /// The [count] days before [date], newest first. Whatever the cache lacks is
  /// fetched in one request; if that fails, what was saved is still shown.
  Future<List> getMultipleApod(String date, {int count = 6}) async {
    final cache = ApodCache.instance;
    await cache.ensureLoaded();
    final format = DateFormat('yyyy-MM-dd');
    final target = format.parse(date);
    final dates = [
      for (var i = 1; i <= count; i++) format.format(DateTime(target.year, target.month, target.day - i)),
    ].where(isArchiveDay).toList();
    if (dates.isEmpty) return [];

    List<String> lacking() => dates.where((d) => cache.get(d) == null && !cache.isMissing(d)).toList();
    var missing = lacking();
    if (missing.isNotEmpty) {
      try {
        await _networkService.getApodRange(format.parse(missing.last), format.parse(missing.first));
        // The site's date filter skips some days that do exist; look those up one by one.
        missing = lacking();
        await Future.wait(missing.map((d) async {
          try {
            await _networkService.getApod(d);
          } on Exception {
            // That day stays out of the list.
          }
        }));
      } on Exception {
        if (!dates.any((d) => cache.get(d) != null)) rethrow;
      }
    }
    return [
      for (final d in dates)
        if (cache.get(d) case final day?) day,
    ];
  }

  /// Saved pictures, most recently added first, leaving out any that can't load now.
  Future<List> getFavoritesApod() async {
    final dates = List<String>.from(await AuthService().getFavorites());
    Object? failure;
    final days = await Future.wait(dates.map((date) async {
      try {
        return await _networkService.getApod(date);
      } on Exception catch (error) {
        failure = error;
        return null;
      }
    }));
    final found = days.whereType<Map<String, dynamic>>().toList().reversed.toList();
    if (found.isEmpty && failure != null) throw failure!;
    return found;
  }
}
