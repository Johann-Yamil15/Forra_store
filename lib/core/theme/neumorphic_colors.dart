import 'package:flutter/material.dart';

class NeumorphicColors {
  final Color background;
  final Color primary;
  final Color secondary;
  final Color text;
  final Color operatorText;
  final Color lightShadow;
  final Color darkShadow;
  final Color error;

  const NeumorphicColors({
    required this.background,
    required this.primary,
    required this.secondary,
    required this.text,
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
    operatorText: Color(0xFF4285F4),
    lightShadow: Color(0xFFFFFFFF),
    darkShadow: Color(0xFFD1D9E6),
    error: Color(0xFFEB5757),
  );
}
