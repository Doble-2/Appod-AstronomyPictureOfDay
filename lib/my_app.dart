import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/domain/use_case.dart';

class MyApp extends StatelessWidget {
  final ApodUseCase apodUseCase;

  const MyApp({super.key, required this.apodUseCase});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: FToastBuilder(),
        debugShowCheckedModeBanner: false,
        title: 'Appod - Astronomy picture of the day',
        theme: ThemeData(
          colorScheme: const ColorScheme.highContrastDark(
            primary: Color.fromARGB(60, 4, 0, 255),
            secondary: Color.fromARGB(66, 255, 0, 0),
          ),
          fontFamily: 'Nasa',
          useMaterial3: true,
        ),
        home: const HomeView());
  }
}
