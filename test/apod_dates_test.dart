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

  test('rejects an invalid date', () {
    expect(shiftDay('not-a-date', 1), isNull);
  });
}
