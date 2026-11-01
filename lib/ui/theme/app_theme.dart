import 'package:flutter/material.dart';

/// Appod's identity (logo, Nasa wordmark, blue and teal) on a modern app system:
/// large radii, glass over photographs, and confident type.
class AppTheme {
  static const display = 'SpaceGrotesk';
  static const text = 'Inter';
  static const radius = 20.0;

  /// The brand gradient, from the logo and splash screen.
  static const brandGradient = LinearGradient(colors: [Color(0xFF3391FF), Color(0xFF00C6B5)]);
  static const onBrand = Color(0xFF04101F);

  static final dark = _build(const ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF5E9EFF),
    onPrimary: Color(0xFF0A0E14),
    secondary: Color(0xFF2DD4BF),
    onSecondary: Color(0xFF0A0E14),
    error: Color(0xFFFF6B6B),
    onError: Color(0xFF2A0A0A),
    surface: Color(0xFF05060A),
    onSurface: Color(0xFFEDEDEF),
    onSurfaceVariant: Color(0xFFA7ADB8),
    surfaceContainer: Color(0xFF0E1118),
    surfaceContainerHighest: Color(0xFF161A24),
    outline: Color(0xFF4A5261),
    outlineVariant: Color(0xFF1E2430),
  ));

  static final light = _build(const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1A73E8),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF00796B),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFD93025),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FC),
    onSurface: Color(0xFF0A0E14),
    onSurfaceVariant: Color(0xFF545C69),
    surfaceContainer: Color(0xFFFFFFFF),
    surfaceContainerHighest: Color(0xFFE9EDF5),
    outline: Color(0xFF8A94A6),
    outlineVariant: Color(0xFFDFE4EC),
  ));

  static ThemeData _build(ColorScheme scheme) {
    final on = scheme.onSurface;
    final dim = scheme.onSurfaceVariant;
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    final textTheme = TextTheme(
      displaySmall: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 40, height: 1.08, letterSpacing: -1, color: on),
      headlineMedium: TextStyle(fontFamily: display, fontWeight: FontWeight.w700, fontSize: 28, height: 1.15, letterSpacing: -0.5, color: on),
      titleLarge: TextStyle(fontFamily: display, fontWeight: FontWeight.w600, fontSize: 20, height: 1.25, letterSpacing: -0.2, color: on),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.3, letterSpacing: -0.1, color: on),
      titleSmall: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3, color: on),
      bodyLarge: TextStyle(fontSize: 16, height: 1.6, color: on),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: dim),
      labelLarge: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      labelMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: dim),
      labelSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, height: 1.4, color: dim),
    );
    return ThemeData(
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      colorScheme: scheme,
      fontFamily: text,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(backgroundColor: Colors.transparent, foregroundColor: on, surfaceTintColor: Colors.transparent, elevation: 0, scrolledUnderElevation: 0),
      filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(shape: shape, minimumSize: const Size(48, 48), padding: const EdgeInsets.symmetric(horizontal: 20))),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(shape: shape, foregroundColor: on, side: BorderSide(color: scheme.outlineVariant), backgroundColor: scheme.surfaceContainerHighest, minimumSize: const Size(48, 48), padding: const EdgeInsets.symmetric(horizontal: 16)),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(shape: shape, minimumSize: const Size(44, 44))),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(minimumSize: const Size(44, 44), foregroundColor: on)),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(shape: shape, foregroundColor: on, selectedBackgroundColor: scheme.primary, selectedForegroundColor: scheme.onPrimary, side: BorderSide(color: scheme.outlineVariant), minimumSize: const Size(44, 48)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: scheme.primary, width: 2)),
      ),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, shape: shape, backgroundColor: scheme.surfaceContainerHighest, contentTextStyle: TextStyle(color: on, fontFamily: text, fontSize: 14)),
      dialogTheme: DialogThemeData(backgroundColor: scheme.surfaceContainer, surfaceTintColor: Colors.transparent, shape: shape),
      datePickerTheme: DatePickerThemeData(backgroundColor: scheme.surfaceContainer, surfaceTintColor: Colors.transparent, headerBackgroundColor: scheme.surfaceContainer, headerForegroundColor: on),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
