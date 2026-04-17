import 'package:flutter/material.dart';
import '../theme/neumorphic_colors.dart';

class NeumorphicStyle {
  /// Caja elevada con estilo neumórfico
  /// [radius] define el radio de las esquinas
  /// [depth] controla la intensidad del relieve (positivo = elevado, negativo = hundido)
  static BoxDecoration elevated(
    NeumorphicColors colors, {
    double radius = 18,
    double depth = 6,
  }) {
    return BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: colors.lightShadow,
          offset: Offset(-depth, -depth),
          blurRadius: depth * 1.5,
        ),
        BoxShadow(
          color: colors.darkShadow,
          offset: Offset(depth, depth),
          blurRadius: depth * 1.5,
        ),
      ],
    );
  }

  /// Caja hundida con estilo neumórfico
  static BoxDecoration inset(
    NeumorphicColors colors, {
    double radius = 18,
    double depth = 4,
  }) {
    return BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: colors.darkShadow,
          offset: Offset(-depth, -depth),
          blurRadius: depth * 1.5,
        ),
        BoxShadow(
          color: colors.lightShadow,
          offset: Offset(depth, depth),
          blurRadius: depth * 1.5,
        ),
      ],
    );
  }
}
