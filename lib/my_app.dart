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
  const MyApp({super.key, apodUseCase, this.initialThemeMode, this.initialLocale});

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
              scaffoldBackgroundColor: const Color(0xFFF5F6FA),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF3391FF),
                secondary: Color(0xFF00C6B5),
                surface: Color(0xFFFFFFFF),
                onSecondary: Colors.white,
                onSurface: Color(0xFF0A0E14),
                error: Color(0xFFFF4D4D),
                onError: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, color: Color(0xFF0A0E14)),
                headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, color: Color(0xFF0A0E14)),
                headlineSmall: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, color: Color(0xFF0A0E14)),
                bodyLarge: TextStyle(color: Color(0xFF0A0E14)),
                bodyMedium: TextStyle(color: Color(0xFF3D4451)),
                titleMedium: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
              ),
              useMaterial3: true,
            ),
            // TEMA OSCURO
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Inter',
              scaffoldBackgroundColor: const Color(0xFF0A0E14),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF3391FF),
                secondary: Color(0xFF00C6B5),
                surface: Color(0xFF1A1F2A),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Color(0xFFE1E6F0),
                error: Color(0xFFFF4D4D),
                onError: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineLarge: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, color: Color(0xFFE1E6F0)),
                headlineMedium: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.bold, color: Color(0xFFE1E6F0)),
                headlineSmall: TextStyle(fontFamily: 'SpaceGrotesk', fontWeight: FontWeight.w500, color: Color(0xFFE1E6F0)),
                bodyLarge: TextStyle(color: Color(0xFFE1E6F0)),
                bodyMedium: TextStyle(color: Color(0xFFE1E6F0)),
                titleMedium: TextStyle(color: Color(0xFF8A94A6), fontSize: 14),
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
                // Reemplaza la URL para que sea compartible
                return MaterialPageRoute(builder: (ctx) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.of(ctx).canPop()) {
                      Navigator.of(ctx).pushReplacementNamed('/apod/$today');
                    } else {
                      Navigator.of(ctx).pushNamed('/apod/$today');
                    }
                  });
                  return const SizedBox.shrink();
                });
              }
              // Ruta dinámica: /apod/yyyy-MM-dd
              final apodMatch = RegExp(r'^/apod/(\d{4}-\d{2}-\d{2})$').firstMatch(name);
              if (apodMatch != null) {
                final date = apodMatch.group(1)!;
                return MaterialPageRoute(builder: (_) => ApodView(date: date));
              }
              return null; // usa rutas definidas arriba
            },
          );
        },
      ),
    );
  }
}
