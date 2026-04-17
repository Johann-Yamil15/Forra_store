import 'package:flutter/material.dart';
import '../../core/theme/neumorphic_colors.dart';
import '../../core/utils/neumorphic_style.dart';
import '../../data/models/producto_preview.dart';

class ProductCard extends StatelessWidget {
  final List<PresentacionProducto> presentaciones;
  final PresentacionProducto? selected;
  final ValueChanged<PresentacionProducto> onSelected;

  const ProductCard({
    super.key,
    required this.presentaciones,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: NeumorphicStyle.elevated(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Presentaciones disponibles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Lista de presentaciones
          ...presentaciones.map(
            (pres) => _PresentationTile(
              pres: pres,
              isSelected: pres == selected,
              onTap: () => onSelected(pres),
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _PresentationTile extends StatelessWidget {
  final PresentacionProducto pres;
  final bool isSelected;
  final VoidCallback onTap;
  final NeumorphicColors colors;

  const _PresentationTile({
    required this.pres,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration:
            isSelected
                ? NeumorphicStyle.inset(colors)
                : NeumorphicStyle.elevated(colors),
        child: Row(
          children: [
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${pres.unidad} ${pres.tamano}',
                    style: TextStyle(
                      color: colors.text,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '\$${pres.precio.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Stock: ${pres.stock}',
                        style: TextStyle(
                          color: colors.text.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Check
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? colors.primary : colors.background,
                boxShadow:
                    isSelected
                        ? []
                        : [
                          BoxShadow(
                            color: colors.darkShadow,
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                        ],
              ),
              child:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
            ),
          ],
        ),
      ),
    );
  }
}
