import 'package:flutter/material.dart';

/// Marca visual de Forra Store.
///
/// Intenta cargar un logo personalizado desde `assets/images/logo.png`
/// (PNG con fondo transparente, o incluso un GIF animado si cambias la
/// extensión abajo). Si el archivo no existe todavía, se dibuja un glifo
/// geométrico de silo como respaldo — nada de íconos genéricos de librería.
///
/// Para poner tu propio diseño: coloca tu imagen en
/// `assets/images/logo.png` y ya se usa automáticamente, sin tocar código.
class BrandMark extends StatelessWidget {
  final double size;
  final Color glyphColor;
  final Color? tileColor;
  final bool showTile;

  const BrandMark({
    super.key,
    this.size = 64,
    required this.glyphColor,
    this.tileColor,
    this.showTile = true,
  });

  static const String assetPath = 'assets/images/logo.png';

  @override
  Widget build(BuildContext context) {
    final content = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) =>
          CustomPaint(size: Size.square(size), painter: _SiloPainter(color: glyphColor)),
    );

    if (!showTile) return SizedBox(width: size, height: size, child: content);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: tileColor ?? glyphColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      padding: EdgeInsets.all(size * 0.16),
      child: content,
    );
  }
}

/// Glifo geométrico de silo — cuerpo redondeado + techo triangular.
/// Representa almacenamiento/campo sin depender de un ícono de librería.
class _SiloPainter extends CustomPainter {
  final Color color;
  const _SiloPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final w = size.width, h = size.height;

    final bodyW = w * 0.5;
    final bodyH = h * 0.46;
    final bodyX = (w - bodyW) / 2;
    final bodyY = h * 0.42;

    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(bodyX, bodyY, bodyW, bodyH),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(bodyRect, paint);

    final roofPath = Path()
      ..moveTo(w / 2, h * 0.12)
      ..lineTo(bodyX - w * 0.06, bodyY + h * 0.04)
      ..lineTo(bodyX + bodyW + w * 0.06, bodyY + h * 0.04)
      ..close();
    canvas.drawPath(roofPath, paint);
  }

  @override
  bool shouldRepaint(covariant _SiloPainter oldDelegate) => oldDelegate.color != color;
}
