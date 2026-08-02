import 'package:flutter/material.dart';
import 'package:nasa_apod/l10n/app_localizations.dart';
import 'package:nasa_apod/provider/locale_provider.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/main_screen.dart';
import 'package:nasa_apod/provider/main_screen_controller.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/pages/register.dart';
import 'package:nasa_apod/ui/pages/login.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  final ThemeMode? initialThemeMode;
  final Locale? initialLocale;
  const MyApp({super.key, this.initialThemeMode, this.initialLocale});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final String _initialRoute = '/';

  @override
  Widget build(BuildContext context) {
    // Gestión de estado solo con Provider, navegación con MaterialApp
    return MultiProvider(
      providers: [
  ChangeNotifierProvider(create: (_) => ThemeProvider(initial: widget.initialThemeMode)),
        ChangeNotifierProvider(create: (_) => MainScreenController()),
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
            // TEMA CLARO
            theme: ThemeData(
              brightness: Brightness.light,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: const Color(0xFFF6F8FC),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF1A73E8), // azul cósmico con contraste 4.5:1 + blanco
                onPrimary: Colors.white,
                secondary: Color(0xFF00796B),
                onSecondary: Colors.white,
                tertiary: Color(0xFF7C4DFF), // violeta nebulosa
                surface: Color(0xFFFFFFFF),
                onSurface: Color(0xFF0A0E14),
                error: Color(0xFFD93025),
                onError: Colors.white,
                outline: Color(0xFF8A94A6),
                surfaceContainerHighest: Color(0xFFE9EDF5),
              ),
              dividerColor: const Color(0x140A0E14),
              cardColor: Colors.white,
              focusColor: const Color(0x1F1A73E8),
              highlightColor: const Color(0x0F1A73E8),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0E14),
                ),
                headlineMedium: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A0E14),
                ),
                headlineSmall: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0E14),
                ),
                bodyLarge: TextStyle(color: Color(0xFF0A0E14), height: 1.5),
                bodyMedium: TextStyle(color: Color(0xFF3D4451), height: 1.5),
                titleMedium: TextStyle(color: Color(0xFF5B6472), fontSize: 14),
              ),
              useMaterial3: true,
            ),
            // TEMA OSCURO — Dark Mode OLED: fondo azul-noche profundo (#0F172A del design system)
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF4C9AFF), // azul cósmico luminoso
                onPrimary: Color(0xFF0A0E14), // texto oscuro sobre azul claro (contraste alto)
                secondary: Color(0xFF2DD4BF),
                onSecondary: Color(0xFF0A0E14),
                tertiary: Color(0xFF8B5CF6), // violeta nebulosa
                surface: Color(0xFF192134), // card azul-noche (del design system)
                onSurface: Color(0xFFE6EAF2),
                error: Color(0xFFFF6B6B),
                onError: Color(0xFF2A0A0A),
                outline: Color(0xFF4A5568),
                surfaceContainerHighest: Color(0xFF232B3D),
              ),
              dividerColor: const Color(0x14FFFFFF), // border rgba(255,255,255,0.08)
              cardColor: const Color(0xFF192134),
              focusColor: const Color(0x2E4C9AFF),
              highlightColor: const Color(0x1F4C9AFF),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                  // glow sutil tipo design system: "minimal glow (text-shadow: 0 0 10px)"
                  shadows: [
                    Shadow(color: Color(0x404C9AFF), blurRadius: 12),
                  ],
                ),
                headlineMedium: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ),
                headlineSmall: TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFFFFF),
                ),
                bodyLarge: TextStyle(color: Color(0xFFE6EAF2), height: 1.5),
                bodyMedium: TextStyle(color: Color(0xFFE6EAF2), height: 1.5),
                titleMedium: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: _initialRoute,
            routes: {
              // Mantener raíz y rutas explícitas de secciones
              '/': (context) => const MainScreen(initialIndex: 0),
              '/home': (context) => const MainScreen(initialIndex: 0),
              '/favorites': (context) => const MainScreen(initialIndex: 1),
              '/settings': (context) => const MainScreen(initialIndex: 2),
              // Compatibilidad previa
              '/appod': (context) => const ApodView(),
              '/register': (context) => const RegisterScreen(),
              '/login': (context) => const LoginScreen(),
              '/get-app': (context) => const MainScreen(initialIndex: 3),
            },
            onGenerateRoute: (settings) {
              final name = settings.name ?? '';
              if (name == '/apod' || name == '/apod/') {
                final now = DateTime.now();
                final y = now.year.toString().padLeft(4, '0');
                final m = now.month.toString().padLeft(2, '0');
                final d = now.day.toString().padLeft(2, '0');
                final today = '$y-$m-$d';
                // Devuelve directamente la ruta con nombre '/apod/yyyy-MM-dd' para fijar la URL.
                return MaterialPageRoute(
                  settings: RouteSettings(name: '/apod/$today'),
                  builder: (_) => ApodView(date: today),
                );
              }
              // Ruta dinámica: /apod/yyyy-MM-dd
              final apodMatch = RegExp(r'^/apod/(\d{4}-\d{2}-\d{2})$').firstMatch(name);
              if (apodMatch != null) {
                final date = apodMatch.group(1)!;
                return MaterialPageRoute(
                  settings: settings,
                  builder: (_) => ApodView(date: date),
                );
              }
              return null; // usa rutas definidas arriba
            },
          );
        },
      ),
    );
  }
}
