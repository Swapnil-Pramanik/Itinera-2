import 'package:flutter/material.dart';

/// Material 3 Theme Configuration for Itinera
class AppTheme {
  AppTheme._();

  // Seed color extracted from design - dark teal/blue
  static const Color _seedColor = Color(0xFF1A1A2E);
  
  // Brand colors
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color surfaceLight = Color(0xFFF5F5F5);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFE53935);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      surface: surfaceLight,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surfaceLight,
      fontFamily: 'RobotoMono',
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: primaryDark, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondary,
          textStyle: const TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: TextStyle(
          fontFamily: 'RobotoMono',
          color: Colors.grey.shade500,
          fontSize: 14,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: primaryDark,
        disabledColor: Colors.grey.shade200,
        labelStyle: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.grey.shade300),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 1.0,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
          letterSpacing: 1.2,
        ),
        labelMedium: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 1.0,
        ),
        labelSmall: TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
