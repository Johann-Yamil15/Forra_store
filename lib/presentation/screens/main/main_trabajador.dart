import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/screens/home/productos_screen.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';

/// ─────────────────────────────────────────────────────────────
/// MAIN SCREEN TRABAJADOR
/// Contenedor principal con navegación neumórfica
/// ─────────────────────────────────────────────────────────────
class MainScreenTrabajador extends StatefulWidget {
  const MainScreenTrabajador({super.key});

  @override
  State<MainScreenTrabajador> createState() => _MainScreenTrabajadorState();
}

class _MainScreenTrabajadorState extends State<MainScreenTrabajador>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;

  late final AnimationController _tabController;
  late final Animation<double> _scaleAnimation;

  final List<Widget> _screens = const [
    ProductosScreen(),
    Placeholder(),
    Placeholder(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront,
      label: 'Productos',
    ),
    _NavItem(
      icon: Icons.shopping_cart_outlined,
      activeIcon: Icons.shopping_cart,
      label: 'Carrito',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Historial',
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

    _tabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _tabController, curve: Curves.easeOutCubic),
    );

    _tabController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    _tabController.forward(from: 0);

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          /// ───────── APP BAR + MENÚ UNIFICADOS ─────────
          Container(
            decoration: NeumorphicStyle.elevated(colors),
            child: Column(
              children: [
                _NeumorphicAppBar(colors: colors),
                _NeumorphicTopMenu(
                  colors: colors,
                  items: _navItems,
                  selectedIndex: _selectedIndex,
                  scaleAnimation: _scaleAnimation,
                  onTap: _onTap,
                ),
              ],
            ),
          ),

          /// ───────── CONTENIDO ─────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: IndexedStack(
                key: ValueKey(_selectedIndex),
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// APP BAR NEUMÓRFICO
/// ─────────────────────────────────────────────────────────────
class _NeumorphicAppBar extends StatelessWidget {
  final NeumorphicColors colors;
  const _NeumorphicAppBar({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(Icons.agriculture, color: colors.primary, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Forra Store',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// MENÚ SUPERIOR NEUMÓRFICO CON LÍNEA INFERIOR
/// ─────────────────────────────────────────────────────────────
class _NeumorphicTopMenu extends StatelessWidget {
  final NeumorphicColors colors;
  final List<_NavItem> items;
  final int selectedIndex;
  final Animation<double> scaleAnimation;
  final ValueChanged<int> onTap;

  const _NeumorphicTopMenu({
    required this.colors,
    required this.items,
    required this.selectedIndex,
    required this.scaleAnimation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: NeumorphicStyle.elevated(colors),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == selectedIndex;
          final item = items[i];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration:
                    selected
                        ? NeumorphicStyle.inset(colors)
                        : NeumorphicStyle.elevated(colors),
                child: ScaleTransition(
                  scale:
                      selected
                          ? scaleAnimation
                          : const AlwaysStoppedAnimation(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        selected ? item.activeIcon : item.icon,
                        size: 22,
                        color:
                            selected
                                ? colors.primary
                                : colors.text.withOpacity(0.7),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.bold : FontWeight.w500,
                          color:
                              selected
                                  ? colors.primary
                                  : colors.text.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // LÍNEA INFERIOR NEÓN
                      Container(
                        height: 3,
                        width: 28,
                        decoration: BoxDecoration(
                          color: selected ? colors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow:
                              selected
                                  ? [
                                    BoxShadow(
                                      color: colors.primary.withOpacity(0.5),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                  : [],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────
/// MODELO DE ITEM DE NAVEGACIÓN
/// ─────────────────────────────────────────────────────────────
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
