import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nasa_apod/data/nasa.dart';

/// Reads APOD from science.nasa.gov, where the archive moved.
///
/// api.nasa.gov/planetary/apod now answers with the NASA logo as the picture,
/// "NASA Science" as the title, and sometimes another day's text. The site's
/// article feed has the real picture, title, credit and explanation, and
/// browsers may read it directly.
class NasaSiteSource {
  static final _articles = Uri.parse('https://science.nasa.gov/wp-json/wp/v2/image-article');

  /// The day's article, or a 404 [NasaApiException] if there is none.
  Future<Map<String, dynamic>> getDay(String date) async {
    final day = DateTime.parse(date);
    // shortcut: the date filter skips about 1 day in 5 that do exist, for no
    // visible reason, so title search covers those. Replace both if NASA fixes
    // its API or publishes an official feed for the archive.
    // per_page must be above 1: with 1, this endpoint can answer with an empty list.
    final byDate = await _fetch(day, day, perPage: 5);
    final found = _forDate(byDate, date);
    if (found != null) return found;
    for (final term in apodSearchTerms(day)) {
      final bySearch = await _request({'search': term, 'per_page': '20', '_fields': 'date,title,content'});
      final match = _forDate(bySearch, date);
      if (match != null) return match;
    }
    throw NasaApiException(statusCode: 404, message: 'No APOD for $date');
  }

  static Map<String, dynamic>? _forDate(List<Map<String, dynamic>> items, String date) {
    for (final item in items) {
      if (item['date'] == date) return item;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getRange(DateTime start, DateTime end) => _fetch(start, end, perPage: 100);

  Future<List<Map<String, dynamic>>> _fetch(DateTime start, DateTime end, {required int perPage}) {
    return _request({
      // "after" leaves out the exact moment, and old articles are dated at 00:00:00.
      'after': '${_iso(DateTime(start.year, start.month, start.day - 1))}T23:59:59',
      'before': '${_iso(end)}T23:59:59',
      'per_page': '$perPage',
      '_fields': 'date,title,content',
    });
  }

  Future<List<Map<String, dynamic>>> _request(Map<String, String> query) async {
    final uri = _articles.replace(queryParameters: query);
    final http.Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const NasaApiException(statusCode: 504, message: 'Gateway Timeout');
    } on http.ClientException catch (e) {
      throw NasaApiException(message: e.message);
    }
    if (response.statusCode != 200) {
      throw NasaApiException(statusCode: response.statusCode, message: 'HTTP ${response.statusCode}');
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! List) throw const NasaApiException(message: 'Unexpected response shape');
    return body.whereType<Map<String, dynamic>>().map(parseApodArticle).whereType<Map<String, dynamic>>().toList();
  }
}

/// How a day's title may be written: old articles pad the day ("June 05").
List<String> apodSearchTerms(DateTime day) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  final prefix = 'APOD: ${day.year} ${months[day.month - 1]}';
  return [
    '$prefix ${day.day}',
    if (day.day < 10) '$prefix ${day.day.toString().padLeft(2, '0')}',
  ];
}

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Turns an article into the shape the app has always used for a day, or null
/// if it is not an APOD or has no picture or video.
Map<String, dynamic>? parseApodArticle(Map<String, dynamic> article) {
  final rawTitle = _text((article['title'] as Map?)?['rendered'] as String? ?? '');
  if (!rawTitle.startsWith('APOD')) return null;
  final date = article['date'] as String? ?? '';
  final html = (article['content'] as Map?)?['rendered'] as String? ?? '';
  if (date.length < 10 || html.isEmpty) return null;

  final result = <String, dynamic>{
    'date': date.substring(0, 10),
    'title': rawTitle.replaceFirst(RegExp(r'^APOD:\s*.*?\s[–—-]\s'), ''),
    'explanation': _explanation(html),
    'service_version': 'site',
  };
  final credit = _credit(html);
  if (credit != null) result['copyright'] = credit;

  final linkedImage = RegExp(r'''<a\s[^>]*href="([^"]+)"[^>]*>\s*<img\s[^>]*src="([^"]+)"''').firstMatch(html);
  final anyImage = RegExp(r'''<img\s[^>]*src="(https://assets\.science\.nasa\.gov/[^"]+)"''').firstMatch(html);
  final source = linkedImage?.group(2) ?? anyImage?.group(1);
  // A video is a YouTube or Vimeo embed, or a file NASA hosts itself.
  final video = RegExp(r'''<(?:iframe|source|video)\s[^>]*src="([^"]+)"''').firstMatch(html)?.group(1);
  if (source != null) {
    final image = _text(source);
    final base = image.split('?').first;
    result['media_type'] = 'image';
    // The site offers its pictures resized on request; 1280 is plenty on screen.
    result['url'] = base.toLowerCase().endsWith('.gif') ? base : '$base?w=1280&fit=clip';
    result['hdurl'] = linkedImage == null ? base : _text(linkedImage.group(1)!);
  } else if (video != null) {
    result['media_type'] = 'video';
    result['url'] = _text(video);
  } else {
    return null;
  }
  return result;
}

String _explanation(String html) {
  final match = RegExp(r'Explanation:?\s*</(?:strong|b)>(.*?)</(?:p|div)>', dotAll: true).firstMatch(html);
  if (match == null) return '';
  // The page ends the text by announcing the next day's picture.
  return _text(match.group(1)!).replaceFirst(RegExp(r"\s*Tomorrow['’]s picture:.*$", dotAll: true), '');
}

String? _credit(String html) {
  final match = RegExp(r'<th[^>]*>\s*Credit[^<]*</th>\s*<td[^>]*>(.*?)</td>', dotAll: true).firstMatch(html);
  if (match == null) return null;
  final credit = _text(match.group(1)!).replaceFirst(RegExp(r'^.{0,30}Credit[^:]*:\s*'), '');
  return credit.isEmpty ? null : credit;
}

/// Plain text from a piece of HTML.
String _text(String html) {
  const named = {'amp': '&', 'lt': '<', 'gt': '>', 'quot': '"', 'apos': "'", 'nbsp': ' '};
  return html
      .replaceAll(RegExp(r'<[^>]+>'), '')
      .replaceAllMapped(RegExp(r'&(#x?[0-9a-fA-F]+|[a-z]+);'), (m) {
        final entity = m.group(1)!;
        if (!entity.startsWith('#')) return named[entity] ?? m.group(0)!;
        final hex = entity.startsWith('#x') || entity.startsWith('#X');
        final code = int.tryParse(entity.substring(hex ? 2 : 1), radix: hex ? 16 : 10);
        return code == null ? m.group(0)! : String.fromCharCode(code);
      })
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
