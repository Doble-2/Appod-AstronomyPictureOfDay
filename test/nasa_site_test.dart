import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/data/nasa_site.dart';

Map<String, dynamic> article(String title, String content, {String date = '2026-10-26T00:05:00'}) => {
      'date': date,
      'title': {'rendered': title},
      'content': {'rendered': content},
    };

void main() {
  const assets = 'https://assets.science.nasa.gov/content/dam/science/cds/apod/apod';

  test('reads a picture with its credit and text, as the site writes them', () {
    final day = parseApodArticle(article(
      'APOD: 2026 October 26 &#8211; M42: The Great Nebula in Orion',
      '<a href="$assets/2026/october/Orion_2000.jpg" target="_blank"><img decoding="async" src="https://assets.science.nasa.gov/dynamicimage/x/Orion_2000.jpg?w=1960&amp;h=2000&amp;fit=clip"></a>'
          '<th scope="row" class="label">Credit &amp; Copyright:</th> <td class="p-sm"> <a href="mailto:x">Roberto Palaia</a> </td>'
          '<p><strong>Explanation:</strong> The <a href="#">Great Nebula</a> isn&#8217;t far. Tomorrow\'s picture: open space</p>',
    ))!;
    expect(day['date'], '2026-10-26');
    expect(day['title'], 'M42: The Great Nebula in Orion');
    expect(day['media_type'], 'image');
    expect(day['url'], 'https://assets.science.nasa.gov/dynamicimage/x/Orion_2000.jpg?w=1280&fit=clip');
    expect(day['hdurl'], '$assets/2026/october/Orion_2000.jpg');
    expect(day['copyright'], 'Roberto Palaia');
    expect(day['explanation'], 'The Great Nebula isn’t far.');
  });

  test('cleans the longer credit wording of older days', () {
    final day = parseApodArticle(article(
      'APOD: 2016 January 1 &#8211; Comet Catalina Tails',
      '<a href="$assets/a.jpg"><img src="$assets/a.jpg?w=1"></a><th>Credit</th><td> Image Credit &amp; <a href="#">Copyright</a>: <a href="#">Jane Doe</a> </td>',
    ))!;
    expect(day['copyright'], 'Jane Doe');
  });

  test('keeps a 1995 GIF as it is, with no credit', () {
    final day = parseApodArticle(article(
      'APOD: 1995 June 16 &#8211; Neutron Star Earth',
      '<a href="$assets/1995/june/e_lens.gif"><img src="$assets/1995/june/e_lens.gif"></a>',
      date: '1995-06-16T00:00:00',
    ))!;
    expect(day['url'], '$assets/1995/june/e_lens.gif');
    expect(day.containsKey('copyright'), isFalse);
  });

  test('reads a video day', () {
    final day = parseApodArticle(article(
      'APOD: 2026 October 18 &#8211; Sonified: Eagle Nebula Pillars',
      '<iframe title="x" src="https://www.youtube.com/embed/abc?feature=oembed"></iframe>',
    ))!;
    expect(day['media_type'], 'video');
    expect(day['url'], 'https://www.youtube.com/embed/abc?feature=oembed');
    expect(day['title'], 'Sonified: Eagle Nebula Pillars');
  });

  test('reads a video file hosted by NASA', () {
    final day = parseApodArticle(article(
      'APOD: 2026 October 28 &#8211; The Mutual Occultation',
      '<video title="x" class="video-js"><source src="$assets/2026/october/occultation.mp4" type="video/mp4"></video>',
    ))!;
    expect(day['media_type'], 'video');
    expect(day['url'], '$assets/2026/october/occultation.mp4');
  });

  test('drops the next-day teaser, however the apostrophe is written', () {
    for (final apostrophe in ["'", '&#8217;', '’']) {
      final day = parseApodArticle(article(
        'APOD: 2026 May 1 &#8211; Moon',
        '<img src="$assets/a.jpg"><p><strong>Explanation:</strong> The Sun.Tomorrow${apostrophe}s picture: open space</p>',
      ))!;
      expect(day['explanation'], 'The Sun.');
    }
  });

  test('ignores articles that are not APOD, or have nothing to show', () {
    expect(parseApodArticle(article('Hubble Sees a Galaxy', '<img src="$assets/a.jpg">')), isNull);
    expect(parseApodArticle(article('APOD: 2026 May 1 &#8211; Empty', '<p>No media</p>')), isNull);
  });
}
