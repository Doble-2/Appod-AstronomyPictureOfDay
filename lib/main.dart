import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/repository.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'my_app.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_web_plugins/url_strategy.dart';

Future<(ThemeMode, Locale)> _preloadPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  // theme
  final themeStr = prefs.getString('themeMode');
  final themeMode = switch (themeStr) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    'system' || _ => ThemeMode.system,
  };
  // locale
  final localeCode = prefs.getString('localeCode') ?? 'en';
  final locale = Locale(localeCode);
  return (themeMode, locale);
}

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que los widgets estén inicializados
  if (kIsWeb) {
    // Usar hash strategy para URLs estables tipo #/apod/yyyy-MM-dd
    setUrlStrategy(const HashUrlStrategy());
  }
  await initializeDateFormatting(); // Inicializa los datos de formato de fecha
  final (themeMode, locale) = await _preloadPrefs();
  final networkService = NetworkService();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apodRepository = ApodRepositoryImpl(networkService);
  final apodBloc = ApodBloc(apodRepository);
  runApp(BlocProvider<ApodBloc>(
    create: (_) => apodBloc,
    child: MyApp(
      initialThemeMode: themeMode,
      initialLocale: locale,
    ),
  ));
}
