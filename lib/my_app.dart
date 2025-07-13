import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/pages/register.dart';
import 'package:nasa_apod/ui/pages/favorites.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/ui/pages/login.dart';
import 'package:nasa_apod/ui/pages/settings.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, apodUseCase});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  final String _initialRoute = '/';

  @override
  Widget build(BuildContext context) {
    // Gestión de estado solo con Provider, navegación con MaterialApp
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
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
                onPrimary: Colors.white,
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
              '/': (context) => const HomeView(),
              '/appod': (context) => const ApodView(),
              '/settings': (context) => SettingsView(authService: AuthService()),
              '/register': (context) => const RegisterScreen(),
              '/login': (context) => const LoginScreen(),
              '/favorites': (context) => FavoritesView(authService: AuthService()),
            },
          );
        },
      ),
    );
  }
}
