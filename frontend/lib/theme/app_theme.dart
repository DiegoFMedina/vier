import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.violetPrimary,
        primary: AppColors.violetPrimary,
        secondary: AppColors.fucsia,
        surface: AppColors.surface,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.manropeTextTheme(),
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineSmall: GoogleFonts.manrope(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        bodySmall: GoogleFonts.manrope(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.violetPrimary, width: 1.5),
        ),
        hintStyle: GoogleFonts.manrope(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.violetPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.violetPrimary,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerColor: AppColors.border,
    );
  }

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: AppColors.violetDeep.withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
