import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary color palette - Child friendly colors
  static const Color primaryColor = Color(0xFF4CAF50); // Green
  static const Color primaryLight = Color(0xFF81C784); // Light Green
  static const Color primaryDark = Color(0xFF388E3C); // Dark Green
  static const Color secondaryColor = Color(0xFF2196F3); // Blue
  static const Color accentColor = Color(0xFFFFC107); // Amber
  static const Color errorColor = Color(0xFFE57373); // Light Red
  static const Color backgroundColor = Color(0xFFF5F5F5); // Light Gray
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF212121); // Dark Gray
  static const Color textSecondary = Color(0xFF757575); // Gray

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Colors.white70;

  // Text Theme (Light)
  static TextTheme textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: textPrimary),
    displayMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
    titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
    titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
    bodyLarge: GoogleFonts.poppins(fontSize: 12, color: textPrimary),
    bodyMedium: GoogleFonts.poppins(fontSize: 11, color: textSecondary),
    labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
  );

  // Text Theme (Dark)
  static TextTheme darkTextTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: darkTextPrimary),
    displayMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: darkTextPrimary),
    titleLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: darkTextPrimary),
    titleMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: darkTextPrimary),
    bodyLarge: GoogleFonts.poppins(fontSize: 12, color: darkTextPrimary),
    bodyMedium: GoogleFonts.poppins(fontSize: 11, color: darkTextSecondary),
    labelLarge: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
  );

  // App Bar Theme (Light)
  static AppBarTheme appBarTheme = const AppBarTheme(
    color: primaryColor,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );

  // App Bar Theme (Dark)
  static AppBarTheme darkAppBarTheme = const AppBarTheme(
    color: darkCard,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  );

  // Card Theme
  static CardThemeData cardTheme = CardThemeData(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  );

  // Button Theme
  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: textTheme.labelLarge,
      elevation: 2,
    ),
  );

  // Text Button Theme
  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      textStyle: textTheme.labelLarge?.copyWith(color: primaryColor),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );

  // Input Decoration Theme (Light)
  static InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: textSecondary),
    hintStyle: const TextStyle(color: Colors.grey),
  );

  // Input Decoration Theme (Dark)
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: errorColor),
    ),
    filled: true,
    fillColor: darkCard,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    labelStyle: const TextStyle(color: darkTextSecondary),
    hintStyle: const TextStyle(color: Colors.grey),
  );

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: inputDecorationTheme,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: primaryColor),
      dividerTheme: const DividerThemeData(
        color: Colors.grey,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      primaryColorLight: primaryLight,
      primaryColorDark: primaryDark,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        background: darkBackground,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: darkAppBarTheme,
      cardTheme: cardTheme.copyWith(color: darkCard),
      elevatedButtonTheme: elevatedButtonTheme,
      textButtonTheme: textButtonTheme,
      inputDecorationTheme: darkInputDecorationTheme,
      textTheme: darkTextTheme,
      iconTheme: const IconThemeData(color: Colors.white),
      dividerTheme: const DividerThemeData(
        color: Colors.white24,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
