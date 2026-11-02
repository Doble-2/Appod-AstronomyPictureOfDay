import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/utils/apod_dates.dart';

void main() {
  test('tabs, including old and untidy addresses', () {
    expect(parseRoute('/').kind, RouteKind.tab);
    expect(parseRoute('/home').path, '/');
    expect(parseRoute('/favorites/').tab, 1);
    expect(parseRoute('/settings?x=1').tab, 2);
    expect(parseRoute('/get-app').tab, 3);
  });

  test('days inside the archive', () {
    expect(parseRoute('/apod/1995-06-16').date, '1995-06-16');
    expect(parseRoute('/apod/2024-02-29').date, '2024-02-29');
    expect(parseRoute('/apod').date, todayIso());
    expect(parseRoute('/appod').path, '/apod/${todayIso()}');
  });

  test('anything else does not exist', () {
    for (final name in ['/nope', '/apod/2026-13-45', '/apod/2023-02-29', '/apod/1995-06-15', '/apod/2999-01-01', '/apod/abc', '/favorites/x']) {
      expect(parseRoute(name).kind, RouteKind.notFound, reason: name);
    }
  });
}
