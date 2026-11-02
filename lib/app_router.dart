import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nasa_apod/routes.dart';

/// The open screens, from the bottom of the stack to the one on show.
@immutable
class AppLocation {
  final List<String> paths;
  const AppLocation(this.paths);

  String get current => paths.last;
}

/// Saves the stack in the browser's history entry, so Back and Forward can
/// restore it exactly. An address with no saved stack opens on top of Home.
class AppRouteParser extends RouteInformationParser<AppLocation> {
  const AppRouteParser();

  static const _separator = '\n';

  @override
  Future<AppLocation> parseRouteInformation(RouteInformation routeInformation) {
    final path = parseRoute(routeInformation.uri.toString()).path;
    final state = routeInformation.state;
    final saved = state is String ? state.split(_separator) : const <String>[];
    final paths = saved.isNotEmpty && saved.last == path
        ? saved
        : [AppRoutes.home, if (path != AppRoutes.home) path];
    return SynchronousFuture(AppLocation(paths));
  }

  @override
  RouteInformation restoreRouteInformation(AppLocation configuration) {
    return RouteInformation(uri: Uri.parse(configuration.current), state: configuration.paths.join(_separator));
  }
}

/// Connects the browser's history to the app's Navigator.
///
/// Screens keep calling Navigator.pushNamed and pop as usual. Without a Router,
/// Flutter's web history only supports Back, so the Forward button did nothing.
class AppRouterDelegate extends RouterDelegate<AppLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppLocation> {
  final Route<void> Function(RouteSettings settings) routeBuilder;
  late final _observer = _StackObserver(_onStackChanged);
  List<String> _initialPaths = const [AppRoutes.home];
  bool _notifyScheduled = false;

  AppRouterDelegate({required this.routeBuilder});

  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static AppRouterDelegate? maybeOf(BuildContext context) {
    final delegate = Router.maybeOf(context)?.routerDelegate;
    return delegate is AppRouterDelegate ? delegate : null;
  }

  @override
  AppLocation? get currentConfiguration {
    final paths = _observer.paths;
    return paths.isEmpty ? null : AppLocation(paths);
  }

  /// Changes the address of the screen on show without adding a history entry.
  void replaceCurrentPath(BuildContext context, String path) {
    if (!_observer.replaceCurrentPath(path)) return;
    Router.neglect(context, notifyListeners);
  }

  // The Navigator reports changes while it builds, when the Router can't react.
  void _onStackChanged() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    scheduleMicrotask(() {
      _notifyScheduled = false;
      notifyListeners();
    });
  }

  @override
  Future<void> setInitialRoutePath(AppLocation configuration) {
    _initialPaths = configuration.paths;
    return SynchronousFuture(null);
  }

  @override
  Future<void> setNewRoutePath(AppLocation configuration) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _initialPaths = configuration.paths;
      return SynchronousFuture(null);
    }
    final wanted = configuration.paths;
    final open = _observer.entries;
    var shared = 0;
    while (shared < wanted.length && shared < open.length && wanted[shared] == open[shared].path) {
      shared++;
    }
    if (shared == 0) {
      navigator.pushNamedAndRemoveUntil(wanted.first, (_) => false);
      shared = 1;
    } else {
      final keep = open[shared - 1].route;
      navigator.popUntil((route) => identical(route, keep));
    }
    for (final path in wanted.skip(shared)) {
      navigator.pushNamed(path);
    }
    return SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      observers: [_observer],
      onGenerateRoute: routeBuilder,
      onGenerateInitialRoutes: (_, __) => [
        for (final path in _initialPaths) routeBuilder(RouteSettings(name: path)),
      ],
    );
  }
}

class _StackEntry {
  final Route<dynamic> route;
  String path;
  _StackEntry(this.route, this.path);
}

/// Keeps the addressable screens. Unnamed routes, such as dialogs and the full
/// screen photo, have no address and aren't tracked.
class _StackObserver extends NavigatorObserver {
  final VoidCallback onChanged;
  final List<_StackEntry> entries = [];
  _StackObserver(this.onChanged);

  List<String> get paths => [for (final entry in entries) entry.path];

  bool replaceCurrentPath(String path) {
    if (entries.isEmpty || entries.last.path == path) return false;
    entries.last.path = path;
    return true;
  }

  void _remove(Route<dynamic> route) {
    final before = entries.length;
    entries.removeWhere((entry) => identical(entry.route, route));
    if (entries.length != before) onChanged();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final name = route.settings.name;
    if (name == null) return;
    entries.add(_StackEntry(route, name));
    onChanged();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _remove(route);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _remove(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final name = newRoute?.settings.name;
    final index = entries.indexWhere((entry) => identical(entry.route, oldRoute));
    if (newRoute == null || name == null || index < 0) return;
    entries[index] = _StackEntry(newRoute, name);
    onChanged();
  }
}
