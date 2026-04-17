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
    final bool isDark = colors.background.computeLuminance() < 0.5;
    return BoxDecoration(
      color: colors.background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark 
            ? colors.lightShadow.withOpacity(0.1) 
            : colors.darkShadow.withOpacity(0.2),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ],
    );
  }

  /// Estilo limpio para contenedores internos
  static BoxDecoration inset(
    NeumorphicColors colors, {
    double radius = 18,
    double depth = 4,
  }) {
    final bool isDark = colors.background.computeLuminance() < 0.5;
    return BoxDecoration(
      color: isDark 
          ? Colors.white.withOpacity(0.03) 
          : Colors.black.withOpacity(0.03),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: isDark 
            ? colors.lightShadow.withOpacity(0.1) 
            : colors.darkShadow.withOpacity(0.15),
        width: 1,
      ),
    );
  }
}
