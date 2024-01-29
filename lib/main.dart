import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/data/repository.dart';
import 'package:nasa_apod/data/nasa.dart';
import 'package:nasa_apod/domain/use_case.dart';
import 'my_app.dart';
import 'package:nasa_apod/ui/blocs/apod_bloc.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Asegúrate de que los widgets estén inicializados
  await initializeDateFormatting(); // Inicializa los datos de formato de fecha
  final networkService = NetworkService();
  await dotenv.load(fileName: ".env");
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final apodRepository = ApodRepositoryImpl(networkService);
  final apodUseCase = ApodUseCase(apodRepository);
  final apodBloc = ApodBloc(apodUseCase);
  FlutterNativeSplash.remove();
  runApp(
    BlocProvider(
      create: (context) => apodBloc,
      child: MyApp(apodUseCase: apodUseCase),
    ),
  );
}
