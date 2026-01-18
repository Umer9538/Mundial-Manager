import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Mundial Manager Brand Colors
      colorScheme: ColorScheme.light(
        primary: AppColors.coolSteelBlue, // #27506D - Headers, key buttons
        onPrimary: AppColors.pureWhite,
        primaryContainer: AppColors.softTealBlue, // #6FAEC9 - Backgrounds
        onPrimaryContainer: AppColors.deepNavyBlue,
        secondary: AppColors.mediumSteelBlue, // #2F5A7D - Brand color
        onSecondary: AppColors.pureWhite,
        secondaryContainer: AppColors.blueGrey, // #6C8BA6
        onSecondaryContainer: AppColors.pureWhite,
        tertiary: AppColors.blue, // #007AFF - Interactive elements
        onTertiary: AppColors.pureWhite,
        error: AppColors.red, // #FF3B30
        onError: AppColors.pureWhite,
        surface: AppColors.pureWhite,
        onSurface: AppColors.deepNavyBlue, // #0F253D - Text
        surfaceContainerHighest: AppColors.surfaceVariant,
        outline: AppColors.blueGrey,
      ),

      // Typography
      textTheme: TextTheme(
        // Headings - Montserrat Bold
        displayLarge: GoogleFonts.montserrat(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.montserrat(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        displaySmall: GoogleFonts.montserrat(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),

        // Body - Roboto
        bodyLarge: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AppColors.textSecondary,
        ),

        // Labels
        labelLarge: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelMedium: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        labelSmall: GoogleFonts.roboto(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),

      // AppBar Theme - Deep Navy Blue for navigation bars
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.deepNavyBlue, // #0F253D
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.pureWhite,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.pureWhite,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          side: const BorderSide(color: AppColors.primary, width: 2),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),

      // Floating Action Button Theme - Blue for interactive elements
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.blue, // #007AFF - Interactive
        foregroundColor: AppColors.pureWhite,
        elevation: 4,
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.pureWhite,
        selectedItemColor: AppColors.coolSteelBlue, // #27506D
        unselectedItemColor: AppColors.blueGrey, // #6C8BA6
        selectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: AppColors.backgroundLight,
        labelStyle: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),

      // Snackbar Theme - Deep Navy Blue background
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.deepNavyBlue, // #0F253D
        contentTextStyle: GoogleFonts.roboto(
          fontSize: 14,
          color: AppColors.pureWhite,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Progress Indicator Theme - Blue for activity indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.blue, // #007AFF
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  // Numbers/Stats Text Style (Roboto Mono)
  static TextStyle get monoTextStyle => GoogleFonts.robotoMono(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle monoTextStyleWithSize(double size) => GoogleFonts.robotoMono(
    fontSize: size,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
