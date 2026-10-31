import 'package:flutter/material.dart';

/// "Observatory": the photograph leads and the interface steps back.
/// One amber accent, like an astronomer's dim light, on neutral surfaces.
class AppTheme {
  static const serif = 'Newsreader';
  static const sans = 'IBMPlexSans';
  static const mono = 'IBMPlexMono';
  static const radius = 8.0;

  static final dark = _build(const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFF5B14C),
    onPrimary: Color(0xFF1E1400),
    secondary: Color(0xFFF5B14C),
    onSecondary: Color(0xFF1E1400),
    error: Color(0xFFFF8A7A),
    onError: Color(0xFF2B0A05),
    surface: Color(0xFF0B0C0E),
    onSurface: Color(0xFFF2F1EE),
    onSurfaceVariant: Color(0xFFA9ACB1),
    surfaceContainer: Color(0xFF16181B),
    surfaceContainerHighest: Color(0xFF212429),
    outline: Color(0xFF5B5F66),
    outlineVariant: Color(0xFF2A2D32),
  ));

  static final light = _build(const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF9A5200),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF9A5200),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF7F8F9),
    onSurface: Color(0xFF15171A),
    onSurfaceVariant: Color(0xFF585C63),
    surfaceContainer: Color(0xFFEDEFF1),
    surfaceContainerHighest: Color(0xFFE1E3E6),
    outline: Color(0xFF8A8E95),
    outlineVariant: Color(0xFFD9DBDF),
  ));

  static ThemeData _build(ColorScheme scheme) {
    final on = scheme.onSurface;
    final dim = scheme.onSurfaceVariant;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    final textTheme = TextTheme(
      displaySmall: TextStyle(fontFamily: serif, fontWeight: FontWeight.w500, fontSize: 44, height: 1.08, letterSpacing: -0.6, color: on),
      headlineMedium: TextStyle(fontFamily: serif, fontWeight: FontWeight.w500, fontSize: 32, height: 1.12, letterSpacing: -0.3, color: on),
      titleLarge: TextStyle(fontFamily: serif, fontWeight: FontWeight.w500, fontSize: 22, height: 1.2, color: on),
      titleMedium: TextStyle(fontFamily: serif, fontWeight: FontWeight.w500, fontSize: 17, height: 1.25, color: on),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3, color: on),
      bodyLarge: TextStyle(fontSize: 17, height: 1.65, color: on),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: dim),
      labelLarge: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      labelMedium: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: dim),
      labelSmall: TextStyle(fontFamily: mono, fontWeight: FontWeight.w400, fontSize: 12, height: 1.4, color: dim),
    );
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      colorScheme: scheme,
      fontFamily: sans,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: on,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: shape, minimumSize: const Size(44, 44), padding: const EdgeInsets.symmetric(horizontal: 18))),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: shape,
          foregroundColor: on,
          side: BorderSide(color: scheme.outline),
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: shape, minimumSize: const Size(44, 44))),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(44, 44), foregroundColor: on)),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          shape: shape,
          foregroundColor: on,
          selectedBackgroundColor: scheme.surfaceContainerHighest,
          selectedForegroundColor: on,
          side: BorderSide(color: scheme.outlineVariant),
          minimumSize: const Size(44, 44),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: scheme.outlineVariant)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: scheme.outlineVariant)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: scheme.primary, width: 2)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: scheme.surfaceContainerHighest,
        height: 64,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? scheme.primary : on),
        ),
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium?.copyWith(color: on)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
        backgroundColor: scheme.surfaceContainerHighest,
        contentTextStyle: TextStyle(color: on, fontFamily: sans, fontSize: 14),
      ),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainer, surfaceTintColor: Colors.transparent, shape: shape),
      datePickerTheme: DatePickerThemeData(backgroundColor: scheme.surfaceContainer, surfaceTintColor: Colors.transparent, headerBackgroundColor: scheme.surfaceContainer, headerForegroundColor: on),
    );
  }
}
