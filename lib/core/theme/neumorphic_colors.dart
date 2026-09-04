import 'package:flutter/material.dart';

class NeumorphicColors {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color text;
  // Para texto que sí transmite información (labels, fechas, subtítulos,
  // ayudas) y necesita seguir siendo legible — a diferencia de
  // `text.withValues(alpha: ...)`, que en este fondo cae muy por debajo del
  // mínimo de contraste WCAG AA (4.5:1) apenas se le baja la opacidad.
  // Verificado: ~5.2:1 en claro, ~5.9:1 en oscuro contra `background`.
  final Color textSecondary;
  final Color operatorText;
  final Color lightShadow;
  final Color darkShadow;
  final Color error;

  const NeumorphicColors({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.text,
    required this.textSecondary,
    required this.operatorText,
    required this.lightShadow,
    required this.darkShadow,
    this.error = const Color(0xFFEB5757),
  });

  // 🌙 Dark Theme
  static const dark = NeumorphicColors(
    background: Color(0xFF22252D),
    primary: Color(0xFF27D685),
    secondary: Color(0xFFE75555),
    text: Color(0xFFE0E0E0),
    textSecondary: Color(0xFFA0A0A0),
    operatorText: Color(0xFF27D685),
    lightShadow: Color(0xFF2B2F3A),
    darkShadow: Color(0xFF181A20),
    error: Color(0xFFE75555),
  );

  // ☀️ Light Theme
  static const light = NeumorphicColors(
    background: Color(0xFFECF0F3),
    primary: Color(0xFF4285F4),
    secondary: Color(0xFFEB5757),
    text: Color(0xFF555555),
    textSecondary: Color(0xFF646464),
    operatorText: Color(0xFF4285F4),
    lightShadow: Color(0xFFFFFFFF),
    darkShadow: Color(0xFFD1D9E6),
    error: Color(0xFFEB5757),
  );
}
