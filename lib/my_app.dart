import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasa_apod/ui/pages/home.dart';
import 'package:nasa_apod/domain/use_case.dart';
import 'ui/widgets/organisms/app_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
          primary: Colors.deepPurple,
          secondary: Colors.deepPurple,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: const OwnAppBar(),
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: HomeView(),
          )),
    );
  }
}
