import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/main_screen.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/pages/register.dart';
import 'package:nasa_apod/ui/pages/login.dart';
import 'package:nasa_apod/ui/theme/app_theme.dart';
import 'package:nasa_apod/utils/apod_dates.dart';
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
            initialRoute: '/',
            onGenerateRoute: _route,
            // A shared link opens that day on top of Home, so Back always has somewhere to go.
            onGenerateInitialRoutes: (name) => [
              _route(const RouteSettings(name: '/'))!,
              if (name != '/' && _route(RouteSettings(name: name)) != null) _route(RouteSettings(name: name))!,
            ],
          );
        },
      ),
    );
  }

  Route<void>? _route(RouteSettings settings) {
    final name = settings.name ?? '';
    final tab = switch (name) {
      '/' || '/home' => 0,
      '/favorites' => 1,
      '/settings' => 2,
      '/get-app' => 3,
      _ => null,
    };
    if (tab != null) {
      // Tabs swap instantly, like tabs.
      return PageRouteBuilder<void>(
        settings: settings,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, _, __) => MainScreen(initialIndex: tab),
      );
    }
    if (name == '/login') return _fade(settings, const LoginScreen());
    if (name == '/register') return _fade(settings, const RegisterScreen());
    // /apod/yyyy-MM-dd opens that day; /apod and the old /appod open today.
    final day = RegExp(r'^/apod/(\d{4}-\d{2}-\d{2})$').firstMatch(name)?.group(1);
    if (day != null) return _fade(settings, ApodView(date: day));
    if (name == '/apod' || name == '/apod/' || name == '/appod') {
      return _fade(RouteSettings(name: '/apod/${todayIso()}'), ApodView(date: todayIso()));
    }
    return null;
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
