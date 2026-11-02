import 'package:flutter/cupertino.dart';
import 'package:nasa_apod/app_router.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/main_screen.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/pages/register.dart';
import 'package:nasa_apod/routes.dart';
import 'package:nasa_apod/ui/pages/login.dart';
import 'package:nasa_apod/ui/pages/not_found.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  final ThemeMode? initialThemeMode;
  final Locale? initialLocale;
  const MyApp({super.key, this.initialThemeMode, this.initialLocale});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  late final AppRouterDelegate _router = AppRouterDelegate(routeBuilder: _route);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gestión de estado solo con Provider, navegación con MaterialApp
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(create: (_) => ThemeProvider(initial: widget.initialThemeMode)),
  ChangeNotifierProvider(create: (_) => LocaleProvider(initial: widget.initialLocale)),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final localeProvider = Provider.of<LocaleProvider>(context);

          // Espera a que ambos providers hayan cargado persistencia.
          // Ya se inyectaron valores iniciales, no se requiere espera.

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            locale: localeProvider.selectedLanguage,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            title: 'Appod - Astronomy picture of the day',
            scrollBehavior: const _AppScrollBehavior(),
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            routerDelegate: _router,
            routeInformationParser: const AppRouteParser(),
          );
        },
      ),
    );
  }

  Route<void> _route(RouteSettings settings) {
    final target = parseRoute(settings.name);
    final named = RouteSettings(name: target.path, arguments: settings.arguments);
    return switch (target.kind) {
      RouteKind.tab => _fade(named, MainScreen(initialIndex: target.tab), duration: 160, rise: false),
      RouteKind.day => _fade(named, ApodView(date: target.date)),
      RouteKind.login => _fade(named, const LoginScreen()),
      RouteKind.register => _fade(named, const RegisterScreen()),
      RouteKind.notFound => _fade(named, const NotFoundPage()),
    };
  }

  Route<void> _fade(RouteSettings settings, Widget page, {int duration = 300, bool rise = true}) {
    // iPhone users expect to swipe back from the screen's edge.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS && rise) {
      return CupertinoPageRoute<void>(settings: settings, builder: (_) => page);
    }
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: Duration(milliseconds: duration),
      reverseTransitionDuration: Duration(milliseconds: duration ~/ 1.5),
      pageBuilder: (context, _, __) => page,
      transitionsBuilder: (context, animation, _, child) {
        if (MediaQuery.of(context).disableAnimations) return child;
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: rise
              ? SlideTransition(position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(curved), child: child)
              : child,
        );
      },
    );
  }
}

/// Lets a mouse drag whatever a finger can, such as panels and carousels.
class _AppScrollBehavior extends MaterialScrollBehavior {
  const _AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {PointerDeviceKind.touch, PointerDeviceKind.mouse, PointerDeviceKind.trackpad, PointerDeviceKind.stylus};
}
