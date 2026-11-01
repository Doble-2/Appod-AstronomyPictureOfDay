import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/utils/apod_dates.dart';

void main() {
  test('moves between days, across month and year ends', () {
    expect(shiftDay('2024-03-01', -1), '2024-02-29');
    expect(shiftDay('2023-12-31', 1), '2024-01-01');
  });

  test('stays inside the archive', () {
    expect(shiftDay('1995-06-16', -1), isNull);
    expect(shiftDay('1995-06-16', 1), '1995-06-17');
    expect(shiftDay(todayIso(), 1), isNull);
  });

  test('archive windows stay in the archive and clear of the last month', () {
    final now = DateTime(2026, 11, 1);
    final random = Random(1);
    for (var i = 0; i < 2000; i++) {
      final (start, end) = randomArchiveWindow(random, now);
      expect(start.isBefore(firstApodDate), isFalse);
      expect(end.isAfter(DateTime(2026, 10, 2)), isFalse);
      expect(end.difference(start).inHours, closeTo(13 * 24, 1));
    }
  });

  test('rejects an invalid date', () {
    expect(shiftDay('not-a-date', 1), isNull);
  });
}
