import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/repository.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/domain/use_case.dart';
import 'package:nasa_apod/ui/blocs/locale_bloc/locale_bloc.dart';
import 'my_app.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  await initializeDateFormatting(); // Inicializa los datos de formato de fecha
  final (themeMode, locale) = await _preloadPrefs();
  final networkService = NetworkService();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apodRepository = ApodRepositoryImpl(networkService);
  final apodUseCase = ApodUseCase(apodRepository);
  final apodBloc = ApodBloc(apodUseCase);
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<LocaleBloc>(create: (_) => LocaleBloc()),
      BlocProvider<ApodBloc>(create: (_) => apodBloc),
    ],
    child: BlocBuilder<LocaleBloc, LocaleState>(
      builder: (context, state) {
        return MyApp(
          apodUseCase: apodUseCase,
          initialThemeMode: themeMode,
          initialLocale: locale,
        );
      },
    ),
  ));
}
