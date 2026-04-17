import 'package:flutter/material.dart';
import '../../core/theme/neumorphic_colors.dart';
import '../../core/utils/neumorphic_style.dart';

typedef PageChanged = void Function(int page);

class ProductPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageChanged onPageChanged;

  const ProductPagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    final range = _visibleRange();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _navButton(
          icon: Icons.chevron_left,
          enabled: currentPage > 1,
          onTap: () => onPageChanged(currentPage - 1),
          colors: colors,
        ),

        const SizedBox(width: 8),

        ...List.generate(range[1] - range[0] + 1, (i) {
          final page = range[0] + i;
          return _pageButton(
            page: page,
            isCurrent: page == currentPage,
            colors: colors,
          );
        }),

        const SizedBox(width: 8),

        _navButton(
          icon: Icons.chevron_right,
          enabled: currentPage < totalPages,
          onTap: () => onPageChanged(currentPage + 1),
          colors: colors,
        ),
      ],
    );
  }

  // ───── PáginaANGE visible (máx 5 páginas) ─────
  List<int> _visibleRange() {
    if (totalPages <= 5) return [1, totalPages];

    if (currentPage <= 3) {
      return [1, 5];
    } else if (currentPage >= totalPages - 2) {
      return [totalPages - 4, totalPages];
    } else {
      return [currentPage - 2, currentPage + 2];
    }
  }

  // ───── Botón página ─────
  Widget _pageButton({
    required int page,
    required bool isCurrent,
    required NeumorphicColors colors,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: () => onPageChanged(page),
        child: Container(
          width: 42,
          height: 38,
          decoration:
              isCurrent
                  ? NeumorphicStyle.inset(colors)
                  : NeumorphicStyle.elevated(colors),
          alignment: Alignment.center,
          child: Text(
            '$page',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isCurrent ? colors.primary : colors.text,
            ),
          ),
        ),
      ),
    );
  }

  // ───── Prev / Next ─────
  Widget _navButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required NeumorphicColors colors,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 44,
          height: 38,
          decoration: NeumorphicStyle.elevated(colors),
          child: Icon(icon, color: colors.text),
        ),
      ),
    );
  }
}
