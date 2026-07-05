import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación, inspirada en el ámbito rural:
/// verdes de cultivo, blancos, grises neutros y tonos tierra.
class AppColors {
  AppColors._();

  // Verde principal (identidad de marca)
  static const Color primaryGreen = Color(0xFF3F7D4C);
  static const Color primaryGreenDark = Color(0xFF2C5A37);
  static const Color primaryGreenLight = Color(0xFF6FA579);

  // Tonos tierra (acentos, categorías)
  static const Color earthBrown = Color(0xFF8A6642);
  static const Color earthLight = Color(0xFFD9C4A3);
  static const Color wheatGold = Color(0xFFC9A227);

  // Neutros
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF6F7F5);
  static const Color grayLight = Color(0xFFE4E6E1);
  static const Color grayMedium = Color(0xFF9AA093);
  static const Color grayDark = Color(0xFF4A4E45);

  // Modo oscuro
  static const Color darkBackground = Color(0xFF141813);
  static const Color darkSurface = Color(0xFF1E241C);
  static const Color darkSurfaceAlt = Color(0xFF262E23);

  // Estados / semántica
  static const Color success = Color(0xFF3F7D4C);
  static const Color warning = Color(0xFFC9A227);
  static const Color danger = Color(0xFFB4462F);
  static const Color info = Color(0xFF3E7CA6);

  // Colores por módulo (para tarjetas del dashboard)
  static const Color cultivos = Color(0xFF3F7D4C);
  static const Color ganado = Color(0xFF8A6642);
  static const Color maquinaria = Color(0xFF3E7CA6);
  static const Color finanzas = Color(0xFFC9A227);
  static const Color calendario = Color(0xFF7A5FA6);
  static const Color reportes = Color(0xFF4A4E45);
}
