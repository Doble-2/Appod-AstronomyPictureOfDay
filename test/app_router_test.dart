import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nasa_apod/app_router.dart';

void main() {
  late AppRouterDelegate router;

  Route<void> build(RouteSettings settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => Scaffold(body: Text('page ${settings.name}')),
      );

  Future<void> open(WidgetTester tester) async {
    router = AppRouterDelegate(routeBuilder: build);
    await tester.pumpWidget(MaterialApp.router(routerDelegate: router, routeInformationParser: const AppRouteParser()));
    await tester.pumpAndSettle();
  }

  Future<void> go(WidgetTester tester, List<String> paths) async {
    await router.setNewRoutePath(AppLocation(paths));
    await tester.pumpAndSettle();
  }

  group('parser', () {
    const parser = AppRouteParser();

    test('an address without a saved stack opens on top of Home', () async {
      final parsed = await parser.parseRouteInformation(RouteInformation(uri: Uri.parse('/apod/2024-01-01')));
      expect(parsed.paths, ['/', '/apod/2024-01-01']);
    });

    test('a saved stack survives the round trip', () async {
      const location = AppLocation(['/', '/apod/2024-01-01', '/apod/2024-01-02']);
      final parsed = await parser.parseRouteInformation(parser.restoreRouteInformation(location));
      expect(parsed.paths, location.paths);
    });

    test('a saved stack for another address is ignored', () async {
      final parsed = await parser.parseRouteInformation(RouteInformation(uri: Uri.parse('/settings'), state: '/\n/favorites'));
      expect(parsed.paths, ['/', '/settings']);
    });
  });

  testWidgets('Back, then Forward, returns to the same screen', (tester) async {
    await open(tester);
    expect(find.text('page /'), findsOneWidget);

    router.navigatorKey.currentState!.pushNamed('/apod/2024-01-01');
    await tester.pumpAndSettle();
    expect(router.currentConfiguration!.paths, ['/', '/apod/2024-01-01']);

    await go(tester, ['/']);
    expect(find.text('page /'), findsOneWidget);
    expect(router.currentConfiguration!.paths, ['/']);

    await go(tester, ['/', '/apod/2024-01-01']);
    expect(find.text('page /apod/2024-01-01'), findsOneWidget);
    expect(router.currentConfiguration!.paths, ['/', '/apod/2024-01-01']);
  });

  testWidgets('moving between tabs replaces the whole stack', (tester) async {
    await open(tester);
    await go(tester, ['/favorites']);
    expect(find.text('page /favorites'), findsOneWidget);
    expect(router.currentConfiguration!.paths, ['/favorites']);
    expect(router.navigatorKey.currentState!.canPop(), isFalse);
  });

  testWidgets('a dialog is closed by Back and has no address', (tester) async {
    await open(tester);
    router.navigatorKey.currentState!.pushNamed('/settings');
    await tester.pumpAndSettle();
    showDialog<void>(context: router.navigatorKey.currentContext!, builder: (_) => const Text('dialog'));
    await tester.pumpAndSettle();
    expect(router.currentConfiguration!.paths, ['/', '/settings']);

    await go(tester, ['/']);
    expect(find.text('dialog'), findsNothing);
    expect(find.text('page /'), findsOneWidget);
  });

  testWidgets('the system back button pops, and leaves the app from the root', (tester) async {
    await open(tester);
    router.navigatorKey.currentState!.pushNamed('/settings');
    await tester.pumpAndSettle();
    expect(await router.popRoute(), isTrue);
    await tester.pumpAndSettle();
    expect(router.currentConfiguration!.paths, ['/']);
    expect(await router.popRoute(), isFalse);
  });
}
