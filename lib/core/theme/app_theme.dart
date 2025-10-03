// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppThemeMode {
  lightBlue,
  darkGreen,
  sciFiBlue,
  warmOrange, // Now a dark/neutral warm theme, more distinctly orange
  lightGreen,
  modernGrey, // Now a dark theme
  deepPurple, // New dark theme
}

class AppTheme {
  // --- Common Component Styles (Dynamic - refer to ColorScheme properties) ---

  // Base text theme
  static TextTheme _baseTextTheme(ColorScheme colorScheme, String fontName) {
    return GoogleFonts.getTextTheme(
      fontName,
      TextTheme(
        displayLarge: TextStyle(color: colorScheme.onSurface),
        displayMedium: TextStyle(color: colorScheme.onSurface),
        displaySmall: TextStyle(color: colorScheme.onSurface),
        headlineLarge: TextStyle(color: colorScheme.onSurface),
        headlineMedium: TextStyle(color: colorScheme.onSurface),
        headlineSmall: TextStyle(color: colorScheme.onSurface),
        titleLarge: TextStyle(color: colorScheme.onSurface),
        titleMedium: TextStyle(color: colorScheme.onSurface),
        titleSmall: TextStyle(color: colorScheme.onSurface),
        bodyLarge: TextStyle(color: colorScheme.onSurface),
        bodyMedium: TextStyle(color: colorScheme.onSurface),
        bodySmall: TextStyle(color: colorScheme.onSurface),
        labelLarge: TextStyle(color: colorScheme.onPrimary),
        labelMedium: TextStyle(color: colorScheme.onSurface),
        labelSmall: TextStyle(color: colorScheme.onSurface),
      ),
    );
  }

  // Elevated Button Style
  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }

  // Input Decoration Theme
  static InputDecorationTheme _inputDecorationTheme(ColorScheme colorScheme) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surfaceContainerHigh,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: TextStyle(
          color: colorScheme.onSurface.withAlpha((255 * 0.6).round())),
    );
  }

  // App Bar Theme
  static AppBarTheme _appBarTheme(ColorScheme colorScheme) {
    return AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Card Theme
  static CardThemeData _cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      margin: const EdgeInsets.all(8),
      color: colorScheme.surfaceContainerHigh,
      shadowColor: colorScheme.shadow.withAlpha((255 * 0.3).round()),
    );
  }

  // Floating Action Button Theme
  static FloatingActionButtonThemeData _fabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    );
  }

  // Bottom Navigation Bar Theme
  static BottomNavigationBarThemeData _bottomNavBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface.withAlpha((255 * 0.6).round()),
    );
  }

  // --- Theme Definitions (Only ColorScheme and Font) ---

  static const Map<AppThemeMode, Map<String, dynamic>> _themeData = {
    AppThemeMode.lightBlue: {
      'colorScheme': ColorScheme.light(
        primary: Color(0xFF64B5F6), // Sky blue
        onPrimary: Colors.white,
        secondary: Color(0xFFBBDEFB), // Lighter blue
        onSecondary: Colors.black,
        surface: Color(0xFFE3F2FD), // Very light blue surface
        onSurface: Color(0xFF2196F3), // Darker blue text
        error: Color(0xFFEF5350), // Standard red error
        onError: Colors.white,
        outline: Color(0xFFA7D9F8),
        outlineVariant: Color(0xFFC7EBFD),
        shadow: Color(0xFF64B5F6),
        surfaceContainerHigh: Color(0xFFCFE8FC), // Added for fill color
      ),
      'fontName': 'Roboto', // A clean, widely used font
    },
    AppThemeMode.darkGreen: {
      'colorScheme': ColorScheme.dark(
        primary: Color(0xFF66BB6A), // Medium Green
        onPrimary: Colors.black,
        secondary: Color(0xFF81C784), // Lighter Green
        onSecondary: Colors.black,
        surface: Color(0xFF2E3D34), // Dark Forest Green
        onSurface: Color(0xFFE8F5E9), // Lightest Green for text
        error: Color(0xFFEF5350), // Standard Red
        onError: Colors.white,
        outline: Color(0xFF4CAF50), // Green outline
        outlineVariant: Color(0xFF66BB6A), // Lighter green outline
        shadow: Color(0xFF66BB6A), // Green shadow
        surfaceContainerHigh:
            Color(0xFF3C4B42), // Slightly lighter dark green for fill
      ),
      'fontName': 'Open Sans', // Readable and pleasant
    },
    AppThemeMode.sciFiBlue: {
      'colorScheme': ColorScheme.dark(
        primary: Color(0xFF00B0FF), // Bright Blue
        onPrimary: Colors.black,
        secondary: Color(0xFF82B1FF), // Luminous lighter blue
        onSecondary: Colors.black,
        surface: Color(0xFF0F1B2A), // Deep dark blue
        onSurface: Color(0xFFE0F7FA), // Light cyan text
        error: Color(0xFFFF5252), // Vibrant red
        onError: Colors.black,
        outline: Color(0xFF00B0FF),
        outlineVariant: Color(0xFF4DD0E1),
        shadow: Color(0xFF00B0FF),
        surfaceContainerHigh:
            Color(0xFF1A2A3A), // Slightly lighter deep blue for fill
      ),
      'fontName': 'Orbitron', // Sci-Fi inspired font
    },
    AppThemeMode.warmOrange: {
      'colorScheme': ColorScheme.dark(
        primary: Color(0xFFFFA726), // More vibrant Orange
        onPrimary: Colors.black,
        secondary: Color(0xFFFFCC80), // Softer, light orange
        onSecondary: Colors.black,
        surface: Color(0xFF421C00), // Very Dark Brown/Orange for deep contrast
        onSurface: Color(0xFFFFE0B2), // Light, warm cream text
        error: Color(0xFFEF5350), // Standard red error
        onError: Colors.white,
        outline: Color(0xFFFB8C00), // Distinct orange outline
        outlineVariant: Color(0xFFFFB74D), // Lighter orange outline
        shadow: Color(0xFFFFA726), // Orange shadow
        surfaceContainerHigh: Color(0xFF5A2A00), // Darker orange-brown for fill
      ),
      'fontName': 'Cabin', // Friendly and warm, yet modern
    },
    AppThemeMode.lightGreen: {
      'colorScheme': ColorScheme.light(
        primary: Color(0xFF81C784), // Soft green
        onPrimary: Colors.black,
        secondary: Color(0xFFC8E6C9), // Lighter green
        onSecondary: Colors.black,
        surface: Color(0xFFE8F5E9), // Very light green surface
        onSurface: Color(0xFF4CAF50), // Darker green text
        error: Color(0xFFE57373), // Red error
        onError: Colors.white,
        outline: Color(0xFFA5D6A7),
        outlineVariant: Color(0xFFC8E6C9),
        shadow: Color(0xFF81C784),
        surfaceContainerHigh: Color(0xFFD4EDD6), // Added for fill color
      ),
      'fontName': 'Nunito', // Soft and rounded, fits light green
    },
    AppThemeMode.modernGrey: {
      'colorScheme': ColorScheme.dark(
        primary: Color(0xFF90A4AE), // Lighter Blue Grey primary
        onPrimary: Colors.black,
        secondary: Color(0xFFB0BEC5), // Even lighter Blue Grey
        onSecondary: Colors.black,
        surface: Color(0xFF263238), // Dark Blue Grey surface
        onSurface: Color(0xFFECEFF1), // Lightest Grey for text
        error: Color(0xFFE57373), // Red error
        onError: Colors.white,
        outline: Color(0xFF455A64), // Dark grey outline
        outlineVariant: Color(0xFF607D8B), // Medium grey outline
        shadow: Color(0xFF90A4AE), // Blue Grey shadow
        surfaceContainerHigh: Color(0xFF37474F), // Medium dark grey for fill
      ),
      'fontName': 'Montserrat', // Modern and clean
    },
    AppThemeMode.deepPurple: {
      'colorScheme': ColorScheme.dark(
        primary: Color(0xFFAB47BC), // Medium Purple
        onPrimary: Colors.white,
        secondary: Color(0xFFCE93D8), // Lighter Purple
        onSecondary: Colors.black,
        surface: Color(0xFF210033), // Very Dark Purple
        onSurface: Color(0xFFF3E5F5), // Lightest Lavender for text
        error: Color(0xFFEF5350), // Standard Red
        onError: Colors.white,
        outline: Color(0xFF7B1FA2), // Darker Purple outline
        outlineVariant: Color(0xFFA567E1), // Medium Purple outline
        shadow: Color(0xFFAB47BC), // Purple shadow
        surfaceContainerHigh: Color(0xFF330055), // Darker purple for fill
      ),
      'fontName': 'Lato', // A clean, readable font for this theme
    },
  };

  // --- Get Theme Method ---
  static ThemeData getTheme(AppThemeMode mode) {
    final theme = _themeData[mode]!;
    final colorScheme = theme['colorScheme'] as ColorScheme;
    final fontName = theme['fontName'] as String;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: _baseTextTheme(colorScheme, fontName),
      appBarTheme: _appBarTheme(colorScheme),
      elevatedButtonTheme: _elevatedButtonTheme(colorScheme),
      inputDecorationTheme: _inputDecorationTheme(colorScheme),
      cardTheme: _cardTheme(colorScheme),
      floatingActionButtonTheme: _fabTheme(colorScheme),
      bottomNavigationBarTheme: _bottomNavBarTheme(colorScheme),
    );
  }

  // --- Get Theme Name Method ---
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.lightBlue:
        return 'Light Blue';
      case AppThemeMode.darkGreen:
        return 'Dark Green';
      case AppThemeMode.sciFiBlue:
        return 'Sci-Fi Blue';
      case AppThemeMode.warmOrange:
        return 'Warm Orange';
      case AppThemeMode.lightGreen:
        return 'Light Green';
      case AppThemeMode.modernGrey:
        return 'Modern Grey';
      case AppThemeMode.deepPurple:
        return 'Deep Purple';
    }
  }

  // --- Get Theme Icon Method ---
  static IconData getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.lightBlue:
        return Icons.water_drop;
      case AppThemeMode.darkGreen:
        return Icons.forest;
      case AppThemeMode.sciFiBlue:
        return Icons.rocket_launch;
      case AppThemeMode.warmOrange:
        return Icons.local_fire_department;
      case AppThemeMode.lightGreen:
        return Icons.grass;
      case AppThemeMode.modernGrey:
        return Icons.layers;
      case AppThemeMode.deepPurple:
        return Icons.star_border;
    }
  }
}