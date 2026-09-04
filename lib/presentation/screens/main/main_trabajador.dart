import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/presentation/providers/cart_provider.dart';
import 'package:forra_store/presentation/screens/home/productos_screen.dart';
import 'package:forra_store/presentation/screens/home/cart_screen.dart';
import 'package:forra_store/presentation/screens/home/pedidos_screen.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';
import 'package:forra_store/presentation/widgets/brand_mark.dart';
import 'package:provider/provider.dart';

class MainScreenTrabajador extends StatefulWidget {
  const MainScreenTrabajador({super.key});

  @override
  State<MainScreenTrabajador> createState() => _MainScreenTrabajadorState();
}

class _MainScreenTrabajadorState extends State<MainScreenTrabajador> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    ProductosScreen(),
    CartScreen(),
    PedidosScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Tienda',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Carrito',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Pedidos',
    ),
    _NavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Perfil',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onBarTap(int index) {
    if (_selectedIndex == index) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutQuint,
    );
    HapticFeedback.selectionClick();
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final cartCount = context.watch<CartProvider>().totalItems;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          /// ───────── APP BAR ─────────
          _InternalAppBar(colors: colors),

          /// ───────── CONTENIDO SWIPEABLE ─────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(
        colors: colors,
        items: _navItems,
        selectedIndex: _selectedIndex,
        onTap: _onBarTap,
        cartItemCount: cartCount,
      ),
    );
  }
}

class _InternalAppBar extends StatelessWidget {
  final NeumorphicColors colors;
  const _InternalAppBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: BoxDecoration(
          color: colors.background,
          boxShadow: [
            BoxShadow(
              color: colors.darkShadow.withValues(alpha: isDark ? 0.28 : 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            BrandMark(
              size: 40,
              glyphColor: colors.primary,
              tileColor: colors.primary.withValues(alpha: 0.12),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Forra Store',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: colors.text,
                ),
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colors.text.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: Icon(Icons.notifications_none_rounded, color: colors.textSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final NeumorphicColors colors;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final int cartItemCount;

  const _FloatingNavBar({
    required this.colors,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    required this.cartItemCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.darkShadow.withValues(alpha: isDark ? 0.25 : 0.10)),
            boxShadow: [
              BoxShadow(
                color: colors.darkShadow.withValues(alpha: isDark ? 0.3 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / items.length;

              return Stack(
                children: [
                  // ── Píldora deslizante ──
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeInOutCubic,
                    left: selectedIndex * itemWidth + 10,
                    top: 10,
                    bottom: 10,
                    width: itemWidth - 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: isDark ? 0.20 : 0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),

                  // ── Items ──
                  Row(
                    children: List.generate(items.length, (index) {
                      final isSelected = selectedIndex == index;
                      final item = items[index];

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTap(index),
                          behavior: HitTestBehavior.opaque,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Icono con badge y escala animada
                              Badge(
                                isLabelVisible: index == 1 && cartItemCount > 0,
                                label: Text(
                                  '$cartItemCount',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                child: AnimatedScale(
                                  scale: isSelected ? 1.18 : 1.0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Icon(
                                      isSelected ? item.activeIcon : item.icon,
                                      key: ValueKey('${index}_$isSelected'),
                                      color: isSelected
                                          ? colors.primary
                                          : colors.textSecondary,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),

                              // Label animado — solo visible cuando está seleccionado
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: AnimatedOpacity(
                                          opacity: isSelected ? 1.0 : 0.0,
                                          duration: const Duration(milliseconds: 200),
                                          child: Text(
                                            item.label,
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: colors.primary,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
