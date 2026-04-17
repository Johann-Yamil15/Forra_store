import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/screens/home/productos_screen.dart';
import 'package:forra_store/presentation/screens/home/cart_screen.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';

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
    Placeholder(child: Center(child: Text('Historial (Próximamente)', style: TextStyle(color: Colors.grey)))),
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
      bottomNavigationBar: _InstagramStyleNavBar(
        colors: colors,
        items: _navItems,
        selectedIndex: _selectedIndex,
        onTap: _onBarTap,
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: colors.background,
          border: Border(
            bottom: BorderSide(
              color: colors.darkShadow.withOpacity(isDark ? 0.2 : 0.4),
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.agriculture, color: colors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Forra Store',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                  color: colors.text,
                ),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none, color: colors.text),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstagramStyleNavBar extends StatelessWidget {
  final NeumorphicColors colors;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _InstagramStyleNavBar({
    required this.colors,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.darkShadow.withOpacity(isDark ? 0.2 : 0.4),
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = selectedIndex == index;
              final item = items[index];

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: isSelected 
                            ? BoxDecoration(
                                color: colors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              )
                            : const BoxDecoration(),
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? colors.primary : colors.text.withOpacity(0.5),
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (isSelected)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
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
