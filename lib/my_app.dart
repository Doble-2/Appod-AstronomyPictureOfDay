import 'package:flutter/material.dart';
import 'package:nasa_apod/data/firebase.dart';
import 'package:nasa_apod/provider/theme_provider.dart';
import 'package:nasa_apod/ui/pages/apod.dart';
import 'package:nasa_apod/ui/pages/create_account.dart';
import 'package:nasa_apod/ui/pages/favorites.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/ui/pages/login.dart';
import 'package:nasa_apod/ui/pages/settings.dart';
import 'package:provider/provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key, apodUseCase});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Colors.blue,
              colorScheme: const ColorScheme.light(
                primary: Colors.blue,
                onPrimary: Colors.white,
                secondary: Colors.green,
                onSecondary: Colors.black,
                surface: Colors.white,
                onSurface: Colors.black,
                error: Colors.red,
                onError: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
                bodyMedium: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              appBarTheme: const AppBarTheme(
                color: Colors.blue,
                iconTheme: IconThemeData(color: Colors.blue),
              ),
              iconTheme: const IconThemeData(
                color: Colors.black,
                size: 24.0,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                labelStyle: TextStyle(color: Colors.blue),
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: Colors.blueGrey,
              colorScheme: const ColorScheme.dark(
                primary: Colors.blue,
                onPrimary: Colors.white,
                secondary: Colors.teal,
                onSecondary: Colors.black,
                surface: Colors.black,
                onSurface: Colors.white,
                error: Colors.red,
                onError: Colors.white,
              ),
              textTheme: const TextTheme(
                headlineMedium: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                bodyMedium: TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                ),
              ),
              appBarTheme: const AppBarTheme(
                color: Colors.blueGrey,
                iconTheme: IconThemeData(color: Colors.blue),
              ),
              iconTheme: const IconThemeData(
                color: Colors.white,
                size: 24.0,
              ),
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueGrey),
                ),
                labelStyle: TextStyle(color: Colors.blueGrey),
              ),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            initialRoute: _initialRoute,
            routes: {
              '/': (context) => const HomeView(),
              '/appod': (context) => const ApodView(),
              '/settings': (context) => SettingsView(authService: AuthService()),
              '/register': (context) => const CreateAccount(),
              '/login': (context) => const LoginScreen(),
              '/favorites': (context) => FavoritesView(authService: AuthService()),
            },
          );
        },
      ),
    );
  }
}
