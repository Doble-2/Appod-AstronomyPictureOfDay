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
        // Define el brillo general del tema (claro u oscuro)
        brightness: Brightness.light,

        // Color principal del tema, utilizado en varios widgets como AppBar, botones, etc.
        primaryColor: Colors.blue,

        // Esquema de colores que define una paleta completa de colores para el tema
        colorScheme: ColorScheme.light(
          primary: Colors.blue, // Color principal
          onPrimary:
              Colors.white, // Color del texto/iconos sobre el color principal
          secondary: Colors.green, // Color secundario
          onSecondary:
              Colors.black, // Color del texto/iconos sobre el color secundario
          surface: Colors.white, // Color de superficies como tarjetas
          onSurface: Colors.black, // Color del texto/iconos sobre superficies

          error: Colors.red, // Color para mensajes de error
          onError:
              Colors.white, // Color del texto/iconos sobre el color de error
        ),

        // Define la apariencia del texto en la aplicación
        textTheme: TextTheme(
          headlineMedium: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold), // Estilo para encabezados grandes
          bodyMedium: TextStyle(
              fontSize: 16.0,
              color: Colors.black), // Estilo para el texto del cuerpo
        ),

        // Configuración específica para la AppBar
        appBarTheme: AppBarTheme(
          color: Colors.blue, // Color de fondo de la AppBar
          iconTheme: IconThemeData(
              color: Colors.blue), // Color de los iconos en la AppBar
        ),

        // Configuración específica para los botones
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue, // Color de fondo de los botones
          textTheme: ButtonTextTheme.primary, // Estilo del texto en los botones
        ),

        // Configuración específica para los iconos
        iconTheme: IconThemeData(
          color: Colors.black, // Color de los iconos
          size: 24.0, // Tamaño de los iconos
        ),

        // Configuración específica para los campos de entrada de texto
        inputDecorationTheme: InputDecorationTheme(
          border:
              OutlineInputBorder(), // Estilo del borde de los campos de entrada
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .blue), // Color del borde cuando el campo está enfocado
          ),
          labelStyle: TextStyle(
              color: Colors.blue), // Estilo del texto de las etiquetas
        ),
      ),

      darkTheme: ThemeData(
        // Define el brillo general del tema (oscuro)
        brightness: Brightness.dark,

        // Color principal del tema, utilizado en varios widgets como AppBar, botones, etc.
        primaryColor: Colors.blueGrey,

        // Esquema de colores que define una paleta completa de colores para el tema oscuro
        colorScheme: ColorScheme.dark(
          primary: Colors.blue, // Color principal
          onPrimary: Colors
              .white, // Color del texto/iconowhites sobre el color principal
          secondary: Colors.teal, // Color secundario
          onSecondary:
              Colors.black, // Color del texto/iconos sobre el color secundario
          surface: Colors.black, // Color de superficies como tarjetas
          onSurface: Colors.white, // Color del texto/iconos sobre superficies

          error: Colors.red[700]!, // Color para mensajes de error
          onError:
              Colors.white, // Color del texto/iconos sobre el color de error
        ),

        // Define la apariencia del texto en la aplicación
        textTheme: TextTheme(
          headlineMedium: TextStyle(
              fontSize: 32.0,
              fontWeight: FontWeight.bold,
              color: Colors.white), // Estilo para encabezados grandes
          bodyMedium: TextStyle(
              fontSize: 16.0,
              color: Colors.white), // Estilo para el texto del cuerpo
        ),

        // Configuración específica para la AppBar
        appBarTheme: AppBarTheme(
          color: Colors.blueGrey, // Color de fondo de la AppBar
          iconTheme: IconThemeData(
              color: Colors.blue), // Color de los iconos en la AppBar
        ),

        // Configuración específica para los botones
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blueGrey, // Color de fondo de los botones
          textTheme: ButtonTextTheme.primary, // Estilo del texto en los botones
        ),

        // Configuración específica para los iconos
        iconTheme: IconThemeData(
          color: Colors.white, // Color de los iconos
          size: 24.0, // Tamaño de los iconos
        ),

        // Configuración específica para los campos de entrada de texto
        inputDecorationTheme: InputDecorationTheme(
          border:
              OutlineInputBorder(), // Estilo del borde de los campos de entrada
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Colors
                    .blueGrey), // Color del borde cuando el campo está enfocado
          ),
          labelStyle: TextStyle(
              color: Colors.blueGrey), // Estilo del texto de las etiquetas
        ),

        // Fuente personalizada para el tema
        fontFamily: 'Nasa',

        // Uso de Material Design 3
        useMaterial3: true,
      ),

      themeMode: ThemeMode
          .system, // Cambia a ThemeMode.light o ThemeMode.dark según tu preferencia
      home: const HomeView(),
    );
  }
}
