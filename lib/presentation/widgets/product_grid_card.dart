import 'package:flutter/material.dart';
import '../../core/theme/neumorphic_colors.dart';
import '../../core/utils/neumorphic_style.dart';
import '../../data/models/producto_preview.dart';

class ProductGridCard extends StatelessWidget {
  final ProductoPreview producto;
  final VoidCallback? onTap;

  const ProductGridCard({super.key, required this.producto, this.onTap});

  bool get hasStock => producto.presentaciones.any((p) => p.stock > 0);

  double get minPrice => producto.presentaciones
      .map((p) => p.precio)
      .reduce((a, b) => a < b ? a : b);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: NeumorphicStyle.elevated(colors),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ───── Imagen ─────
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: _buildImage(),
                  ),

                  // Stock badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _badge(
                      text: hasStock ? 'Stock' : 'Agotado',
                      color: hasStock ? colors.primary : colors.secondary,
                    ),
                  ),

                  // Precio
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: _badge(
                      text: 'Desde \$${minPrice.toStringAsFixed(0)}',
                      color: colors.background.withOpacity(0.85),
                      textColor: colors.text,
                    ),
                  ),
                ],
              ),
            ),

            // ───── Contenido ─────
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombreProducto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: NeumorphicStyle.inset(colors, radius: 8),
                      child: Text(
                        producto.categoria.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───── Helpers ─────

  Widget _buildImage() {
    if (producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty) {
      return Image.network(
        producto.imagenUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Colors.grey.withOpacity(0.15),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _badge({
    required String text,
    required Color color,
    Color? textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: textColor ?? Colors.white,
        ),
      ),
    );
  }
}
