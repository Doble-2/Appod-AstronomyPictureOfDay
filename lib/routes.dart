import 'package:nasa_apod/utils/apod_dates.dart';

/// Every address in the app. Screens navigate with these, never with raw text.
class AppRoutes {
  static const home = '/';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const getApp = '/get-app';
  static const login = '/login';
  static const register = '/register';
  static String day(String date) => '/apod/$date';
  static const tabs = [home, favorites, settings, getApp];
}

enum RouteKind { tab, day, login, register, notFound }

class RouteTarget {
  final RouteKind kind;
  /// The tab index, for [RouteKind.tab].
  final int tab;
  /// The yyyy-MM-dd date, for [RouteKind.day].
  final String? date;
  /// The address the screen should show.
  final String path;
  const RouteTarget(this.kind, this.path, {this.tab = 0, this.date});
}

/// Turns an address into a screen. Query strings and trailing slashes don't
/// matter, and a date outside the archive is a page that doesn't exist.
RouteTarget parseRoute(String? name) {
  var path = Uri.tryParse(name ?? '')?.path ?? '';
  if (path.length > 1 && path.endsWith('/')) path = path.substring(0, path.length - 1);
  if (path.isEmpty || path == '/home') return const RouteTarget(RouteKind.tab, AppRoutes.home);
  final tab = AppRoutes.tabs.indexOf(path);
  if (tab >= 0) return RouteTarget(RouteKind.tab, path, tab: tab);
  if (path == AppRoutes.login) return RouteTarget(RouteKind.login, path);
  if (path == AppRoutes.register) return RouteTarget(RouteKind.register, path);
  // /apod and the old /appod open today's picture.
  if (path == '/apod' || path == '/appod') {
    final today = todayIso();
    return RouteTarget(RouteKind.day, AppRoutes.day(today), date: today);
  }
  final date = RegExp(r'^/apod/(\d{4}-\d{2}-\d{2})$').firstMatch(path)?.group(1);
  if (date != null && isArchiveDay(date)) return RouteTarget(RouteKind.day, path, date: date);
  return RouteTarget(RouteKind.notFound, path);
}
