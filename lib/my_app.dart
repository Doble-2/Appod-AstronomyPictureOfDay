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

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: localeProvider.selectedLanguage,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            title: 'Appod - Astronomy picture of the day',
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: AppRoutes.home,
            onGenerateRoute: _route,
            // A shared link opens that day on top of Home, so Back always has somewhere to go.
            // Any address opens on top of Home, so Back always has somewhere to go.
            onGenerateInitialRoutes: (name) => [
              _route(const RouteSettings(name: AppRoutes.home)),
              if (parseRoute(name).path != AppRoutes.home) _route(RouteSettings(name: name)),
            ],
          );
        },
      ),
    );
  }

  Route<void> _route(RouteSettings settings) {
    final target = parseRoute(settings.name);
    final named = RouteSettings(name: target.path, arguments: settings.arguments);
    return switch (target.kind) {
      // Tabs swap instantly, like tabs.
      RouteKind.tab => PageRouteBuilder<void>(
          settings: named,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, _, __) => MainScreen(initialIndex: target.tab),
        ),
      RouteKind.day => _fade(named, ApodView(date: target.date)),
      RouteKind.login => _fade(named, const LoginScreen()),
      RouteKind.register => _fade(named, const RegisterScreen()),
      RouteKind.notFound => _fade(named, const NotFoundPage()),
    };
  }

  Route<void> _fade(RouteSettings settings, Widget page) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 160),
      pageBuilder: (context, _, __) => page,
      transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
    );
  }
}
