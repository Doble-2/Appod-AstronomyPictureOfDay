import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/data/apod_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final cache = ApodCache.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    cache.clearForTest();
  });

  test('keeps days across launches', () async {
    await cache.ensureLoaded();
    cache.put('2020-01-01', {'title': 'Betelgeuse'});
    await cache.save();
    cache.clearForTest();
    await cache.ensureLoaded();
    expect(cache.get('2020-01-01')?['title'], 'Betelgeuse');
  });

  test('forgets the least recently used day beyond the limit', () async {
    await cache.ensureLoaded();
    cache.put('first', {});
    cache.put('second', {});
    expect(cache.get('first'), isNotNull); // "second" is now the oldest in use.
    for (var i = 0; i < ApodCache.maxDays - 1; i++) {
      cache.put('filler$i', {});
    }
    expect(cache.get('second'), isNull);
    expect(cache.get('first'), isNotNull);
  });

  test('finds the newest saved day whatever the order', () async {
    await cache.ensureLoaded();
    expect(cache.latestDate, isNull);
    cache.put('2026-10-30', {});
    cache.put('2026-10-31', {});
    cache.put('1999-01-01', {});
    expect(cache.latestDate, '2026-10-31');
  });

  test('survives a damaged store', () async {
    SharedPreferences.setMockInitialValues({'apod_cache_v2': 'not json'});
    await cache.ensureLoaded();
    expect(cache.get('2020-01-01'), isNull);
  });
}
