import 'package:intl/intl.dart';

final _iso = DateFormat('yyyy-MM-dd');

/// The first Astronomy Picture of the Day.
final firstApodDate = DateTime(1995, 6, 16);

DateTime _today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String todayIso() => _iso.format(_today());

/// The day [days] away from [date], or null if it is outside the archive.
String? shiftDay(String date, int days) {
  final parsed = DateTime.tryParse(date);
  if (parsed == null) return null;
  // DateTime(y, m, d + n) keeps calendar days correct across daylight saving.
  final shifted = DateTime(parsed.year, parsed.month, parsed.day + days);
  if (shifted.isBefore(firstApodDate) || shifted.isAfter(_today())) return null;
  return _iso.format(shifted);
}

/// A date such as "October 31, 2026", in the reader's language.
String longDate(String date, String locale) {
  final parsed = DateTime.tryParse(date);
  return parsed == null ? date : DateFormat.yMMMMd(locale).format(parsed);
}

/// Whether [date] is a real yyyy-MM-dd calendar day with a picture in the archive.
bool isArchiveDay(String date) {
  final parsed = DateTime.tryParse(date);
  // DateTime rolls impossible days over (Feb 30 becomes March), so compare back.
  if (parsed == null || _iso.format(parsed) != date) return false;
  return !parsed.isBefore(firstApodDate) && !parsed.isAfter(_today());
}
