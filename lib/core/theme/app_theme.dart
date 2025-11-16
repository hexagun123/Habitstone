// lib/theme/app_theme.dart
// This file centralizes the application's theming logic.
// It defines multiple theme modes, their corresponding color schemes, fonts,
// and custom styles for various Flutter widgets. This allows for a consistent
// look and feel across the app and provides an easy way to switch between themes.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// An enumeration of the available application themes.
enum AppThemeMode {
  light,
  sciFiBlue,
  warmOrange,
  modernGrey,
}

/// A utility class for managing and providing `ThemeData` for the application.
///
/// This class contains static methods and definitions for different visual themes.
/// It separates color schemes from component styles, making the theme structure
/// modular and easy to maintain.
class AppTheme {
  // --- Common Component Styles (Dynamic - refer to ColorScheme properties) ---
  // These private methods generate theme data for specific widgets using a
  // provided ColorScheme. This ensures that UI components are styled consistently
  // within any selected theme.

  /// Creates a base [TextTheme] using Google Fonts with colors from the provided [colorScheme].
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

  /// Creates an [ElevatedButtonThemeData] with styles derived from the [colorScheme].
  static ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: colorScheme.primary, // Button background
        foregroundColor: colorScheme.onPrimary, // Text and icon color
      ),
    );
  }

  /// Creates an [InputDecorationTheme] for text fields based on the [colorScheme].
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
          color: colorScheme.onSurface
              .withAlpha((255 * 0.6).round())), // Hint text with 60% opacity
    );
  }

  /// Creates an [AppBarTheme] using colors from the [colorScheme].
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

  /// Creates a [CardThemeData] with styles derived from the [colorScheme].
  static CardThemeData _cardTheme(ColorScheme colorScheme) {
    return CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
      ),
      margin: const EdgeInsets.all(8),
      color: colorScheme.surfaceContainerHigh,
      shadowColor: colorScheme.shadow
          .withAlpha((255 * 0.3).round()), // Shadow with 30% opacity
    );
  }

  /// Creates a [FloatingActionButtonThemeData] based on the [colorScheme].
  static FloatingActionButtonThemeData _fabTheme(ColorScheme colorScheme) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    );
  }

  /// Creates a [BottomNavigationBarThemeData] using the [colorScheme].
  static BottomNavigationBarThemeData _bottomNavBarTheme(
      ColorScheme colorScheme) {
    return BottomNavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      selectedItemColor: colorScheme.primary,
      unselectedItemColor: colorScheme.onSurface
          .withAlpha((255 * 0.6).round()), // Unselected item with 60% opacity
    );
  }

  // --- Theme Definitions (Only ColorScheme and Font) ---
  /// A map containing the core properties (color scheme and font name) for each [AppThemeMode].
  static const Map<AppThemeMode, Map<String, dynamic>> _themeData = {
    AppThemeMode.light: {
      'colorScheme': ColorScheme.light(
        primary: Color(0xFF1565C0), // Deeper, more saturated blue
        onPrimary: Colors.white,
        secondary: Color(0xFF42A5F5), // Medium blue for secondary
        onSecondary: Colors.white,
        surface: Color(0xFFF8F9FA), // Clean white with slight grey tint
        onSurface: Color(0xFF212121), // Near-black for high contrast text
        error: Color(0xFFD32F2F), // Deeper red for better contrast
        onError: Colors.white,
        outline: Color.fromARGB(255, 115, 115, 115), // Medium grey for borders
        outlineVariant:
            Color.fromARGB(255, 162, 162, 162), // Light grey for subtle borders
        shadow: Color(0xFF000000), // Black for proper shadows
        surfaceContainerHigh:
            Color(0xFFEEEEEE), // Light grey for elevated surfaces
      ),
      'fontName': 'Roboto',
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
  };

  // --- Public Getters ---
  // These static methods provide a public interface to access theme properties.

  /// Constructs and returns a full [ThemeData] object for the given [AppThemeMode].
  ///
  /// This method retrieves the base color scheme and font, then applies all the
  /// custom component themes to build the final, complete theme.
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

  /// Returns a user-friendly string name for the given [AppThemeMode].
  static String getThemeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light Theme';
      case AppThemeMode.sciFiBlue:
        return 'Sci-Fi Blue';
      case AppThemeMode.warmOrange:
        return 'Warm Orange';
      case AppThemeMode.modernGrey:
        return 'Modern Grey';
    }
  }

  /// Returns an [IconData] representative of the given [AppThemeMode].
  /// Useful for displaying theme options in a UI picker.
  static IconData getThemeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.water_drop;
      case AppThemeMode.sciFiBlue:
        return Icons.rocket_launch;
      case AppThemeMode.warmOrange:
        return Icons.local_fire_department;
      case AppThemeMode.modernGrey:
        return Icons.layers;
    }
  }
}
