// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Add new themes
enum AppThemeMode { light, dark, sciFi, warm, lightBlue, greenLight }

class AppTheme {
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.dark:
        return _darkTheme;
      case AppThemeMode.sciFi:
        return _sciFiTheme;
      case AppThemeMode.warm:
        return _warmTheme;
      case AppThemeMode.light:
        return _lightTheme;
      case AppThemeMode.lightBlue: // New
        return _lightBlueTheme;
      case AppThemeMode.greenLight: // New
        return _greenLightTheme;
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
      case AppThemeMode.warm:
        return 'Warm';
      case AppThemeMode.lightBlue: // New
        return 'Light Blue';
      case AppThemeMode.greenLight: // New
        return 'Green Light';
    }
  }

  // Base text theme
  static final TextTheme _baseTextTheme = GoogleFonts.robotoTextTheme();

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
      error: Color(0xFFDC2626),
    ),
    textTheme: _baseTextTheme.apply(
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
      error: Color(0xFFEF4444),
    ),
    textTheme: _baseTextTheme.apply(
      displayColor: Color(0xFFE2E8F0),
      bodyColor: Color(0xFFCBD5E1),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF1E293B),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFF1E293B),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF3B82F6),
    ),
  );

  // Sci-Fi Theme - Improved
  static final ThemeData _sciFiTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FFE0),
      secondary: Color(0xFFFF00FF),
      surface: Color(0xFF0A0A2A),
      error: Color(0xFFFF4D4D),
    ),
    textTheme: GoogleFonts.orbitronTextTheme().apply(
      displayColor: Color(0xFF00FFE0),
      bodyColor: Color(0xFFA0F0FF),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF0A0A3A),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(Color(0xFFFF00FF)),
        foregroundColor: WidgetStateProperty.all(Colors.black),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFF00FFE0), width: 1),
      ),
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
        borderSide: BorderSide(color: Color(0xFF5555AA)),
      ),
      filled: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFF00FF),
      foregroundColor: Colors.black,
    ),
  );

  // Warm Theme - Improved
  static final ThemeData _warmTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFFFA500),
      secondary: Color(0xFFFFD700),
      surface: Color(0xFF1A1A1A),
      error: Color(0xFFFF3333),
    ),
    textTheme: _baseTextTheme.apply(
      displayColor: Color(0xFFFFA500),
      bodyColor: Color(0xFFFFD700),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFF222222),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: _elevatedButtonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all(Color(0xFFFFA500)),
        foregroundColor: WidgetStateProperty.all(Colors.black),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFFFA500), width: 1),
      ),
      margin: const EdgeInsets.all(8),
      color: Color(0xFF222222),
      shadowColor: Color(0x66FFA500),
    ),
    inputDecorationTheme: _inputDecorationTheme.copyWith(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFFFFA500)),
      ),
      filled: false,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFFFA500),
      foregroundColor: Colors.black,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF222222),
      selectedItemColor: Color(0xFFFFA500),
    ),
  );

  // New Light Blue Theme
  static final ThemeData _lightBlueTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1E88E5),
      secondary: Color(0xFF4FC3F7),
      surface: Color(0xFFE3F2FD),
      error: Color(0xFFE53935),
    ),
    textTheme: _baseTextTheme.apply(
      displayColor: Color(0xFF0D47A1),
      bodyColor: Color(0xFF1976D2),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFFE3F2FD),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFFE1F5FE),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF1E88E5),
    ),
  );

  // New Green Light Theme
  static final ThemeData _greenLightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF66BB6A),
      surface: Color(0xFFE8F5E9),
      error: Color(0xFFC62828),
    ),
    textTheme: _baseTextTheme.apply(
      displayColor: Color(0xFF1B5E20),
      bodyColor: Color(0xFF388E3C),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: Color(0xFFE8F5E9),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: _elevatedButtonStyle),
    inputDecorationTheme: _inputDecorationTheme,
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      color: Color(0xFFDCEDC8),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2E7D32),
    ),
  );
}
