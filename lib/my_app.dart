import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/domain/use_case.dart';
import 'package:nasa_apod/ui/widgets/organisms/nav_bar.dart';
import 'ui/widgets/organisms/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  final ApodUseCase apodUseCase;

  MyApp({required this.apodUseCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Apod Development',
        theme: ThemeData(
          colorScheme: const ColorScheme.highContrastDark(
            primary: Color.fromARGB(60, 4, 0, 255),
            secondary: Color.fromARGB(66, 255, 0, 0),
          ),
          fontFamily: GoogleFonts.inter().fontFamily,
          useMaterial3: true,
        ),
        home: HomeView());
  }
}
