import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/providers/admin_provider.dart';
import 'package:forra_store/presentation/providers/cart_provider.dart';
import 'package:forra_store/presentation/screens/admin/cliente_admin_screen.dart';
import 'package:forra_store/presentation/screens/admin/producto_admin_screen.dart';
import 'package:forra_store/presentation/screens/home/cart_screen.dart';
import 'package:forra_store/presentation/screens/home/productos_screen.dart';
import 'package:forra_store/presentation/screens/profile/profile_screen.dart';
import 'package:forra_store/presentation/widgets/brand_mark.dart';
import 'package:forra_store/data/services/admin_service.dart';
import 'package:forra_store/data/services/venta_service.dart';
import 'package:forra_store/presentation/screens/home/pedido_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';

// ════════════════════════════════════════════════════════════════
//  SHELL PRINCIPAL
// ════════════════════════════════════════════════════════════════

class MainScreenAdmin extends StatefulWidget {
  const MainScreenAdmin({super.key});

  @override
  State<MainScreenAdmin> createState() => _MainScreenAdminState();
}

class _MainScreenAdminState extends State<MainScreenAdmin> {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _screens = const [
    _DashboardAdminScreen(),
    _VenderAdminScreen(),
    _ReportesAdminScreen(),
    _TiendaAdminScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Inicio'),
    _NavItem(icon: Icons.point_of_sale_outlined, activeIcon: Icons.point_of_sale, label: 'Vender'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Reportes'),
    _NavItem(icon: Icons.store_outlined, activeIcon: Icons.store, label: 'Tienda'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Perfil'),
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

  void _onPageChanged(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          _AdminAppBar(colors: colors),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _AdminNavBar(
        colors: colors,
        items: _navItems,
        selectedIndex: _selectedIndex,
        onTap: _onBarTap,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  APP BAR
// ════════════════════════════════════════════════════════════════

class _AdminAppBar extends StatelessWidget {
  final NeumorphicColors colors;
  const _AdminAppBar({required this.colors});

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Forra Store', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: colors.text)),
                  Text('Panel de Administración', style: TextStyle(fontSize: 11, color: colors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('Admin', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.primary)),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  NAV BAR FLOTANTE
// ════════════════════════════════════════════════════════════════

class _AdminNavBar extends StatelessWidget {
  final NeumorphicColors colors;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AdminNavBar({
    required this.colors,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
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
                              AnimatedScale(
                                scale: isSelected ? 1.18 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    key: ValueKey('${index}_$isSelected'),
                                    color: isSelected ? colors.primary : colors.text.withValues(alpha: 0.35),
                                    size: 24,
                                  ),
                                ),
                              ),
                              AnimatedSize(
                                duration: const Duration(milliseconds: 220),
                                curve: Curves.easeInOut,
                                child: isSelected
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          item.label,
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: colors.primary, letterSpacing: 0.4),
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
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ════════════════════════════════════════════════════════════════
//  TAB 1 — DASHBOARD
// ════════════════════════════════════════════════════════════════

class _DashboardAdminScreen extends StatefulWidget {
  const _DashboardAdminScreen();
  @override
  State<_DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<_DashboardAdminScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _dashboard;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AdminService.getDashboard();
      if (mounted) setState(() { _dashboard = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'No se pudo cargar el dashboard: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final productos = context.watch<AdminProvider>().productos;
    final alertasProductos = productos.where((p) => p.tieneAlerta).toList();

    final ventasHoy = (_dashboard?['ventasHoy'] as num?)?.toInt() ?? 0;
    final totalHoy = (_dashboard?['totalHoy'] as num?)?.toDouble() ?? 0;
    final totalSemana = (_dashboard?['totalSemana'] as num?)?.toDouble() ?? 0;
    final topProductos = (_dashboard?['topProductos'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final ventasRecientes = (_dashboard?['ventasRecientes'] as List?)?.cast<Map<String, dynamic>>() ?? const [];

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _cargar,
        child: _loading
            ? ListView(
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 100),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _error != null
                ? ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 80),
                        child: Column(
                          children: [
                            Icon(Icons.cloud_off_outlined, color: colors.text.withValues(alpha: 0.3), size: 32),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: colors.text.withValues(alpha: 0.5), fontSize: 12)),
                            ),
                            const SizedBox(height: 12),
                            TextButton(onPressed: _cargar, child: const Text('Reintentar')),
                          ],
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                    children: [
                      _buildGreeting(colors),
                      const SizedBox(height: 24),
                      _buildKpiRow(colors, ventasHoy, totalHoy, totalSemana),
                      const SizedBox(height: 28),
                      if (alertasProductos.isNotEmpty) ...[
                        _sectionTitle('Alertas de Stock', Icons.warning_amber_rounded, colors, color: colors.secondary),
                        const SizedBox(height: 12),
                        ...alertasProductos.map((p) => _StockAlertTile(producto: p, colors: colors)),
                        const SizedBox(height: 28),
                      ],
                      _sectionTitle('Más vendidos', Icons.trending_up, colors),
                      const SizedBox(height: 12),
                      _buildTopProductos(colors, topProductos),
                      const SizedBox(height: 28),
                      _sectionTitle('Ventas recientes', Icons.receipt_long_outlined, colors),
                      const SizedBox(height: 12),
                      if (ventasRecientes.isEmpty)
                        _emptyHint('Sin ventas registradas aún', colors)
                      else
                        ...ventasRecientes.map((v) => _VentaResumenTile(venta: v, colors: colors)),
                    ],
                  ),
      ),
    );
  }

  Widget _buildGreeting(NeumorphicColors colors) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Buenos días' : hour < 18 ? 'Buenas tardes' : 'Buenas noches';
    final dateStr = DateFormat("EEEE, d 'de' MMMM", 'es_MX').format(DateTime.now());
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, Admin', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: colors.text)),
              const SizedBox(height: 4),
              Text(dateStr, style: TextStyle(fontSize: 13, color: colors.text.withValues(alpha: 0.45))),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: NeumorphicStyle.elevated(colors, radius: 14),
          child: Icon(Icons.notifications_none_rounded, color: colors.text.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildKpiRow(NeumorphicColors colors, int ventasHoy, double totalHoy, double totalSemana) {
    final fmt = NumberFormat.simpleCurrency(locale: 'es_MX', name: '\$');
    return Row(
      children: [
        Expanded(child: _KpiCard(label: 'Ventas hoy', value: '$ventasHoy', icon: Icons.shopping_bag_outlined, colors: colors)),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Total hoy', value: fmt.format(totalHoy), icon: Icons.attach_money_rounded, colors: colors, highlight: true)),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Esta semana', value: fmt.format(totalSemana), icon: Icons.calendar_view_week_outlined, colors: colors)),
      ],
    );
  }

  Widget _buildTopProductos(NeumorphicColors colors, List<Map<String, dynamic>> topProductos) {
    if (topProductos.isEmpty) return _emptyHint('Sin datos de ventas aún', colors);

    final top = topProductos.take(3).toList();
    final maxVal = (top.first['totalVendido'] as num).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeumorphicStyle.elevated(colors, radius: 16),
      child: Column(
        children: List.generate(top.length, (i) {
          final nombre = top[i]['nombreProducto'] as String;
          final valor = (top[i]['totalVendido'] as num).toInt();
          return Padding(
            padding: EdgeInsets.only(bottom: i < top.length - 1 ? 16 : 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        color: i == 0 ? const Color(0xFFFFD700) : i == 1 ? const Color(0xFFC0C0C0) : const Color(0xFFCD7F32),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text('${i + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white))),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(nombre, style: TextStyle(fontWeight: FontWeight.w600, color: colors.text, fontSize: 13), overflow: TextOverflow.ellipsis)),
                    Text('$valor uds.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: maxVal > 0 ? valor / maxVal : 0,
                    minHeight: 5,
                    backgroundColor: colors.primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(colors.primary.withValues(alpha: 0.7 - i * 0.15)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon, NeumorphicColors colors, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color ?? colors.primary),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
      ],
    );
  }

  Widget _emptyHint(String text, NeumorphicColors colors) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(text, style: TextStyle(color: colors.text.withValues(alpha: 0.35), fontSize: 13)),
      );
}

// ════════════════════════════════════════════════════════════════
//  TAB 2 — VENDER (Productos + Carrito)
// ════════════════════════════════════════════════════════════════

class _VenderAdminScreen extends StatefulWidget {
  const _VenderAdminScreen();
  @override
  State<_VenderAdminScreen> createState() => _VenderAdminScreenState();
}

class _VenderAdminScreenState extends State<_VenderAdminScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(5),
            decoration: NeumorphicStyle.inset(colors, radius: 20),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: colors.text.withValues(alpha: 0.4),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              dividerColor: Colors.transparent,
              tabs: [
                const Tab(text: 'Productos'),
                Tab(text: cartCount > 0 ? 'Carrito ($cartCount)' : 'Carrito'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                ProductosScreen(),
                CartScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TAB 3 — REPORTES
// ════════════════════════════════════════════════════════════════

class _ReportesAdminScreen extends StatefulWidget {
  const _ReportesAdminScreen();
  @override
  State<_ReportesAdminScreen> createState() => _ReportesAdminScreenState();
}

class _ReportesAdminScreenState extends State<_ReportesAdminScreen> {
  // -1 = rango personalizado elegido con el calendario.
  int _periodo = 1;
  bool _generandoPdf = false;
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _reporte;

  late DateTime _desde;
  late DateTime _hasta;

  static const _labels = ['Hoy', 'Semana', 'Mes'];

  @override
  void initState() {
    super.initState();
    _seleccionarPeriodo(1);
  }

  void _seleccionarPeriodo(int i) {
    final hoy = DateTime.now();
    final hoyDate = DateTime(hoy.year, hoy.month, hoy.day);
    setState(() {
      _periodo = i;
      switch (i) {
        case 0:
          _desde = hoyDate;
          _hasta = hoyDate;
        case 1:
          _desde = hoyDate.subtract(const Duration(days: 6));
          _hasta = hoyDate;
        case 2:
          _desde = DateTime(hoy.year, hoy.month, 1);
          _hasta = hoyDate;
      }
    });
    _cargarReporte();
  }

  Future<void> _elegirRangoPersonalizado() async {
    final rango = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _desde, end: _hasta),
    );
    if (rango == null) return;
    setState(() {
      _periodo = -1;
      _desde = DateTime(rango.start.year, rango.start.month, rango.start.day);
      _hasta = DateTime(rango.end.year, rango.end.month, rango.end.day);
    });
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await AdminService.getReportes(_desde, _hasta);
      if (mounted) setState(() { _reporte = data; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'No se pudo cargar el reporte: $e'; _loading = false; });
    }
  }

  Future<void> _compartirPdf() async {
    if (_generandoPdf) return;
    setState(() => _generandoPdf = true);
    try {
      final bytes = await AdminService.getReportePdf(_desde, _hasta);
      await Printing.layoutPdf(onLayout: (_) async => bytes, name: 'reporte_forrastore.pdf');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo generar el PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generandoPdf = false);
    }
  }

  String get _labelRango {
    if (_periodo >= 0) return _labels[_periodo];
    final fmt = DateFormat('d/MM/yy');
    return _desde == _hasta ? fmt.format(_desde) : '${fmt.format(_desde)} – ${fmt.format(_hasta)}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    final total = (_reporte?['totalVentas'] as num?)?.toDouble() ?? 0;
    final descuento = (_reporte?['descuentoTotal'] as num?)?.toDouble() ?? 0;
    final numVentas = (_reporte?['numVentas'] as num?)?.toInt() ?? 0;
    final gananciaTotal = (_reporte?['gananciaTotal'] as num?)?.toDouble() ?? 0;
    final gananciaPorProducto = (_reporte?['gananciaPorProducto'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final desglose = (_reporte?['desgloseDiario'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final ventas = (_reporte?['ventas'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final maxBarra = desglose.fold(0.0, (m, e) => math.max(m, (e['total'] as num).toDouble()));

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        onRefresh: _cargarReporte,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          children: [
            // Selector período
            Container(
              padding: const EdgeInsets.all(6),
              decoration: NeumorphicStyle.inset(colors, radius: 20),
              child: Row(
                children: [
                  ...List.generate(_labels.length, (i) {
                    final sel = _periodo == i;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _seleccionarPeriodo(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: sel
                              ? BoxDecoration(
                                  color: colors.primary,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                                )
                              : const BoxDecoration(),
                          child: Text(
                            _labels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: sel ? Colors.white : colors.text.withValues(alpha: 0.4)),
                          ),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _elegirRangoPersonalizado,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: _periodo == -1
                          ? BoxDecoration(
                              color: colors.primary,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                            )
                          : const BoxDecoration(),
                      child: Icon(Icons.calendar_month_outlined, size: 18, color: _periodo == -1 ? Colors.white : colors.text.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
            ),
            if (_periodo == -1) ...[
              const SizedBox(height: 8),
              Text(_labelRango, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors.primary)),
            ],
            const SizedBox(height: 14),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _generandoPdf ? null : _compartirPdf,
                icon: _generandoPdf
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                      )
                    : Icon(Icons.picture_as_pdf_outlined, color: colors.primary),
                label: Text(
                  _generandoPdf ? 'Generando...' : 'Imprimir / Compartir PDF',
                  style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: NeumorphicStyle.elevated(colors, radius: 16),
                child: Column(
                  children: [
                    Icon(Icons.cloud_off_outlined, color: colors.text.withValues(alpha: 0.3), size: 32),
                    const SizedBox(height: 8),
                    Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: colors.text.withValues(alpha: 0.5), fontSize: 12)),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _cargarReporte, child: const Text('Reintentar')),
                  ],
                ),
              )
            else ...[
              // Hero total
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total ${_labelRango.toLowerCase()}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
                          const SizedBox(height: 6),
                          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (descuento > 0)
                            Text('Descuentos: \$${descuento.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$numVentas', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Text('ventas', style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: NeumorphicStyle.elevated(colors, radius: 16),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, color: Colors.green.shade600, size: 20),
                    const SizedBox(width: 10),
                    Text('Ganancia estimada', style: TextStyle(fontSize: 13, color: colors.text.withValues(alpha: 0.6))),
                    const Spacer(),
                    Text('\$${gananciaTotal.toStringAsFixed(2)}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade600)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Gráfico
              Text('Desglose', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: NeumorphicStyle.elevated(colors, radius: 16),
                child: Column(
                  children: desglose.map((e) {
                    final etiqueta = e['etiqueta'] as String;
                    final valor = (e['total'] as num).toDouble();
                    final pct = maxBarra > 0 ? valor / maxBarra : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          SizedBox(width: 46, child: Text(etiqueta, style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.5)))),
                          Expanded(
                            child: Stack(
                              children: [
                                Container(height: 20, decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(6))),
                                FractionallySizedBox(
                                  widthFactor: pct.clamp(0.0, 1.0),
                                  child: Container(height: 20, decoration: BoxDecoration(color: colors.primary.withValues(alpha: valor > 0 ? 0.75 : 0), borderRadius: BorderRadius.circular(6))),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 58,
                            child: Text(
                              valor > 0 ? '\$${valor.toStringAsFixed(0)}' : '—',
                              textAlign: TextAlign.right,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: valor > 0 ? colors.primary : colors.text.withValues(alpha: 0.3)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              if (gananciaPorProducto.isNotEmpty) ...[
                Text('Ganancia por producto', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: NeumorphicStyle.elevated(colors, radius: 16),
                  child: Column(
                    children: gananciaPorProducto.map((g) {
                      final nombre = g['nombreProducto'] as String? ?? '';
                      final presentacion = g['descripcionPresentacion'] as String? ?? '';
                      final ganancia = (g['ganancia'] as num?)?.toDouble() ?? 0;
                      final ingreso = (g['ingreso'] as num?)?.toDouble() ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nombre, style: TextStyle(fontWeight: FontWeight.w600, color: colors.text, fontSize: 13), overflow: TextOverflow.ellipsis),
                                  Text(presentacion, style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.5))),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('\$${ganancia.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade600)),
                                Text('de \$${ingreso.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 10, color: colors.text.withValues(alpha: 0.4))),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              Text('Detalle de ventas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: colors.text)),
              const SizedBox(height: 12),
              if (ventas.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  alignment: Alignment.center,
                  child: Text('Sin ventas en este período', style: TextStyle(color: colors.text.withValues(alpha: 0.3), fontSize: 13)),
                )
              else
                ...ventas.map((v) => _VentaResumenTile(venta: v, colors: colors)),
            ],
          ],
        ),
      ),
    );
  }
}

class _VentaResumenTile extends StatefulWidget {
  final Map<String, dynamic> venta;
  final NeumorphicColors colors;
  const _VentaResumenTile({required this.venta, required this.colors});

  @override
  State<_VentaResumenTile> createState() => _VentaResumenTileState();
}

class _VentaResumenTileState extends State<_VentaResumenTile> {
  bool _cargando = false;

  Future<void> _abrirDetalle() async {
    if (_cargando) return;
    setState(() => _cargando = true);
    try {
      final id = int.parse(widget.venta['id'].toString());
      final pedido = await VentaService.getVentaDetalle(id);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(builder: (_) => PedidoDetailScreen(pedido: pedido)));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir el detalle: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final venta = widget.venta;
    final fecha = DateTime.parse(venta['fecha'] as String).toLocal();
    final fmt = DateFormat('dd/MM • HH:mm');
    final nombreCliente = venta['nombreCliente'] as String? ?? 'Venta al Público';
    final numProductos = (venta['numProductos'] as num?)?.toInt() ?? 0;
    final total = (venta['totalFinal'] as num?)?.toDouble() ?? 0;

    return GestureDetector(
      onTap: _abrirDetalle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: NeumorphicStyle.elevated(colors, radius: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: _cargando
                  ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                  : Icon(Icons.receipt_outlined, color: colors.primary, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombreCliente, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 13)),
                  Text('$numProductos producto(s) · ${fmt.format(fecha)}',
                      style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.5))),
                ],
              ),
            ),
            Text('\$${total.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: colors.primary, fontSize: 14)),
            Icon(Icons.chevron_right, color: colors.text.withValues(alpha: 0.25), size: 18),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TAB 3 — TIENDA (Productos + Clientes)
// ════════════════════════════════════════════════════════════════

class _TiendaAdminScreen extends StatefulWidget {
  const _TiendaAdminScreen();
  @override
  State<_TiendaAdminScreen> createState() => _TiendaAdminScreenState();
}

class _TiendaAdminScreenState extends State<_TiendaAdminScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final isProductos = _tabController.index == 0;

    return Scaffold(
      backgroundColor: colors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isProductos) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductoFormScreen()));
          } else {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClienteFormScreen()));
          }
        },
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          isProductos ? 'Nuevo Producto' : 'Nuevo Cliente',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(5),
            decoration: NeumorphicStyle.inset(colors, radius: 20),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: colors.text.withValues(alpha: 0.4),
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              dividerColor: Colors.transparent,
              tabs: const [Tab(text: 'Productos'), Tab(text: 'Clientes')],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _ProductosAdminList(colors: colors),
                _ClientesAdminList(colors: colors),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Lista de Productos ────────────────────────────────────────

class _ProductosAdminList extends StatelessWidget {
  final NeumorphicColors colors;
  const _ProductosAdminList({required this.colors});

  @override
  Widget build(BuildContext context) {
    final productos = context.watch<AdminProvider>().productos;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: productos.length,
      itemBuilder: (context, i) {
        final p = productos[i];
        final statusColor = p.stockStatus == 'critico'
            ? colors.secondary
            : p.stockStatus == 'alerta'
                ? Colors.orange
                : colors.primary;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: NeumorphicStyle.elevated(colors, radius: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.inventory_2_outlined, color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
                        Text(p.categoria, style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  // Acciones
                  _ActionMenu(
                    colors: colors,
                    items: [
                      _MenuAction(icon: Icons.edit_outlined, label: 'Editar', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => ProductoFormScreen(producto: p)));
                      }),
                      _MenuAction(icon: Icons.add_box_outlined, label: 'Reabastecer', onTap: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => ProductoRestockSheet(producto: p),
                        );
                      }),
                      _MenuAction(icon: Icons.delete_outline, label: 'Eliminar', isDestructive: true, onTap: () {
                        _confirmDeleteProducto(context, p);
                      }),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...p.presentaciones.map((pr) {
                final c = pr.enAlerta ? colors.secondary : colors.text.withValues(alpha: 0.5);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        pr.enAlerta ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                        size: 14,
                        color: c,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          pr.descripcion,
                          style: TextStyle(fontSize: 12, color: colors.text.withValues(alpha: 0.65)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${pr.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: colors.text.withValues(alpha: 0.5))),
                              const SizedBox(width: 12),
                              Text('${pr.stock} uds.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteProducto(BuildContext context, ProductoAdmin p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar producto?', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        content: Text('Se eliminará "${p.nombre}" y sus presentaciones. Esta acción no se puede deshacer.',
            style: TextStyle(color: colors.text.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: TextStyle(color: colors.text))),
          TextButton(
            onPressed: () {
              context.read<AdminProvider>().deleteProducto(p.id);
              Navigator.pop(ctx);
            },
            child: Text('Eliminar', style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ── Lista de Clientes ─────────────────────────────────────────

class _ClientesAdminList extends StatelessWidget {
  final NeumorphicColors colors;
  const _ClientesAdminList({required this.colors});

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<AdminProvider>().clientes;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      itemCount: clientes.length,
      itemBuilder: (context, i) {
        final c = clientes[i];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ClienteDescuentosScreen(cliente: c)),
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: NeumorphicStyle.elevated(colors, radius: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: colors.primary.withValues(alpha: 0.12),
                      child: Text(c.nombre[0], style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 13)),
                          Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 11, color: colors.text.withValues(alpha: 0.4)),
                              const SizedBox(width: 4),
                              Text(c.telefono, style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.45))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _ActionMenu(
                      colors: colors,
                      items: [
                        _MenuAction(icon: Icons.percent, label: 'Descuentos', onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ClienteDescuentosScreen(cliente: c)));
                        }),
                        _MenuAction(icon: Icons.edit_outlined, label: 'Editar datos', onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ClienteFormScreen(cliente: c)));
                        }),
                        _MenuAction(icon: Icons.delete_outline, label: 'Eliminar', isDestructive: true, onTap: () {
                          _confirmDeleteCliente(context, c);
                        }),
                      ],
                    ),
                  ],
                ),
                if (c.precios.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: NeumorphicStyle.inset(colors, radius: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${c.precios.length} precio${c.precios.length != 1 ? "s" : ""} especial${c.precios.length != 1 ? "es" : ""}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.5))),
                        const SizedBox(height: 8),
                        ...c.precios.map((pr) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${pr.productoNombre} • ${pr.presentacionDesc}',
                                      style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.6)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('\$${pr.precioLista.toStringAsFixed(2)}',
                                              style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.35), decoration: TextDecoration.lineThrough)),
                                          const SizedBox(width: 6),
                                          Text('\$${pr.precioEspecial.toStringAsFixed(2)}',
                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
                if (c.precios.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Sin precios especiales — toca para configurar',
                        style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.3))),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteCliente(BuildContext context, ClienteAdmin c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar cliente?', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        content: Text('Se eliminarán todos sus precios especiales. Esta acción no se puede deshacer.',
            style: TextStyle(color: colors.text.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancelar', style: TextStyle(color: colors.text))),
          TextButton(
            onPressed: () {
              context.read<AdminProvider>().deleteCliente(c.id);
              Navigator.pop(ctx);
            },
            child: Text('Eliminar', style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  WIDGETS COMPARTIDOS
// ════════════════════════════════════════════════════════════════

class _MenuAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;
  const _MenuAction({required this.icon, required this.label, required this.onTap, this.isDestructive = false});
}

class _ActionMenu extends StatelessWidget {
  final NeumorphicColors colors;
  final List<_MenuAction> items;
  const _ActionMenu({required this.colors, required this.items});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: colors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(Icons.more_vert, color: colors.text.withValues(alpha: 0.5), size: 20),
      onSelected: (i) => items[i].onTap(),
      itemBuilder: (_) => List.generate(
        items.length,
        (i) => PopupMenuItem<int>(
          value: i,
          child: Row(
            children: [
              Icon(items[i].icon, size: 18, color: items[i].isDestructive ? colors.secondary : colors.primary),
              const SizedBox(width: 10),
              Text(
                items[i].label,
                style: TextStyle(
                  color: items[i].isDestructive ? colors.secondary : colors.text,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final NeumorphicColors colors;
  final bool highlight;

  const _KpiCard({required this.label, required this.value, required this.icon, required this.colors, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: highlight
          ? BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 5))],
            )
          : NeumorphicStyle.elevated(colors, radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: highlight ? Colors.white70 : colors.primary),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: highlight ? Colors.white : colors.text), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: highlight ? Colors.white60 : colors.text.withValues(alpha: 0.45))),
        ],
      ),
    );
  }
}

class _StockAlertTile extends StatelessWidget {
  final ProductoAdmin producto;
  final NeumorphicColors colors;
  const _StockAlertTile({required this.producto, required this.colors});

  @override
  Widget build(BuildContext context) {
    final alertas = producto.presentaciones.where((p) => p.enAlerta).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: colors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.inventory_2_outlined, color: colors.secondary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(producto.nombre, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 13)),
                Text(alertas.map((p) => '${p.descripcion}: ${p.stock} uds.').join(' · '), style: TextStyle(fontSize: 11, color: colors.secondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: colors.secondary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Text('Stock bajo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colors.secondary)),
          ),
        ],
      ),
    );
  }
}

