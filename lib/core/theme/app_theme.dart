// app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode { light, dark, sciFi, soloLeveling }

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.sciFi:
        return _sciFiTheme;
      case AppThemeMode.soloLeveling:
        return _soloLevelingTheme;
      case AppThemeMode.light:
      default:
        return _lightTheme;
    }
  }

  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.sciFi:
        return 'Sci-Fi';
      case AppThemeMode.soloLeveling:
        return 'Solo Leveling';
    }
  }

  // Base text theme with Orbitron font
  static final TextTheme _TextTheme = GoogleFonts.robotoTextTheme();

  // Common styles
  static final ButtonStyle _elevatedButtonStyle = ElevatedButton.styleFrom(
    elevation: 6,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    filled: true,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );

  // Light Theme
  static final ThemeData _lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF64748B),
      surface: Color(0xFFFFFFFF),
      background: Color(0xFFF8FAFC),
      error: Color(0xFFDC2626),
    ),
    textTheme: _TextTheme.apply(
      displayColor: Color(0xFF0F172A),
      bodyColor: Color(0xFF334155),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Colors.white,
    ),
  );

  // Dark Theme
  static final ThemeData _darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6),
      secondary: Color(0xFF94A3B8),
      surface: Color(0xFF1E293B),
      background: Color(0xFF0F172A),
      error: Color(0xFFEF4444),
    ),
    textTheme: _TextTheme.apply(
      displayColor: Color(0xFFE2E8F0),
      bodyColor: Color(0xFFCBD5E1),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFF1E293B),
    ),
  );

  // Sci-Fi Theme
  static final ThemeData _sciFiTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FFE0),
      secondary: Color(0xFFFF00FF),
      surface: Color(0xFF0A0A2A),
      background: Color(0xFF00001A),
      error: Color(0xFFFF4D4D),
    ),
    textTheme: _TextTheme.apply(
      displayColor: Color(0xFF00FFE0),
      bodyColor: Color(0xFFA0F0FF),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFF0A0A3A),
      shadowColor: Color(0x6600FFE0),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF00FFE0)),
      ),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF5555AA))),
    ),
  );

  // Solo Leveling Theme
  static final ThemeData _soloLevelingTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFA500),
      secondary: Color(0xFFFFD700),
      surface: Color(0xFF1A1A1A),
      background: Color(0xFF0D0D0D),
      error: Color(0xFFFF3333),
    ),
    textTheme: _TextTheme.apply(
      displayColor: Color(0xFFFFA500),
      bodyColor: Color(0xFFFFD700),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFF222222),
      shadowColor: Color(0x66FFA500),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFFFA500))),
    ),
  );
}
