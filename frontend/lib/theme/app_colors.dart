import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color violetDeep = Color(0xFF3B1370);
  static const Color violetPrimary = Color(0xFF6D28D9);
  static const Color violetSoft = Color(0xFF9F7AEA);
  static const Color violetSurface = Color(0xFFF3EEFC);

  static const Color fucsia = Color(0xFFE0399B);
  static const Color orangeSoft = Color(0xFFFB9B5D);

  static const Color background = Color(0xFFF8F7FC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1F1147);
  static const Color textSecondary = Color(0xFF6B6480);
  static const Color border = Color(0xFFE7E1F7);

  static const List<Color> heroGradient = [violetDeep, violetPrimary];
  static const List<Color> ctaGradient = [fucsia, orangeSoft];

  static Color estadoColor(String estado) {
    switch (estado) {
      case 'EN_PROGRESO':
        return orangeSoft;
      case 'COMPLETADO':
        return const Color(0xFF34A853);
      default:
        return violetSoft;
    }
  }
}
