import 'package:flutter/material.dart';
import 'package:forra_store/data/models/producto_preview.dart';
import 'package:forra_store/data/services/producto_service.dart';
import 'package:forra_store/presentation/screens/home/product_detail_screen.dart';
import 'package:forra_store/presentation/widgets/product_grid_card.dart';
import 'package:forra_store/presentation/widgets/product_pagination.dart';

import '../../../core/theme/neumorphic_colors.dart';
import '../../../core/utils/neumorphic_style.dart';

class ProductosScreen extends StatefulWidget {
  const ProductosScreen({super.key});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen>
    with TickerProviderStateMixin {
  String _query = '';
  List<ProductoPreview> _productos = [];
  bool _isLoading = true;
  String? _errorMsg;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String? _selectedCategoria;
  String? _selectedSubcategoria;
  String? _selectedUso;

  static const int _itemsPerPage = 20;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _cargarProductos();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────── LOGICA ───────────────────

  void _onSearchChanged(String q) {
    setState(() {
      _query = q.trim();
      _currentPage = 1;
    });
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoria = null;
      _selectedSubcategoria = null;
      _selectedUso = null;
      _currentPage = 1;
    });
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  List<String> get _categorias =>
      _productos.map((e) => e.categoria).toSet().toList();
  List<String> get _subcategorias =>
      _productos.map((e) => e.subcategoria).toSet().toList();
  List<String> get _usos => _productos.map((e) => e.uso).toSet().toList();

  List<ProductoPreview> get _allMatches {
    final q = _normalize(_query);
    return _productos.where((p) {
      final name = _normalize(p.nombreProducto);
      final desc = _normalize(p.descripcionProducto);
      final cat = _normalize(p.categoria);
      final sub = _normalize(p.subcategoria);
      final uso = _normalize(p.uso);

      final matchQuery =
          _query.isEmpty ||
          name.contains(q) ||
          desc.contains(q) ||
          cat.contains(q) ||
          sub.contains(q) ||
          uso.contains(q);

      return matchQuery &&
          (_selectedCategoria == null || p.categoria == _selectedCategoria) &&
          (_selectedSubcategoria == null ||
              p.subcategoria == _selectedSubcategoria) &&
          (_selectedUso == null || p.uso == _selectedUso);
    }).toList();
  }

  List<ProductoPreview> get _currentItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = start + _itemsPerPage;
    if (start >= _allMatches.length) return [];
    return _allMatches.sublist(
      start,
      end > _allMatches.length ? _allMatches.length : end,
    );
  }

  int get _totalPages => (_allMatches.length / _itemsPerPage).ceil();

  // ─────────────────── UI ───────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: CircularProgressIndicator(color: colors.primary)),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 56, color: colors.text.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(_errorMsg!, textAlign: TextAlign.center, style: TextStyle(color: colors.text.withValues(alpha: 0.6))),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _cargarProductos,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary, foregroundColor: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildSearch(colors),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildFilters(colors),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _buildHeader(colors),
              ),
            ),
            _currentItems.isNotEmpty
                ? SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _buildGrid(_currentItems),
                )
                : SliverToBoxAdapter(child: _empty(colors)),
            if (_totalPages > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ProductPagination(
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: _onPageChanged,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  // ─────────────────── WIDGETS ───────────────────

  Widget _buildSearch(NeumorphicColors colors) {
    return Container(
      decoration: NeumorphicStyle.inset(colors, radius: 12),
      child: TextField(
        onChanged: _onSearchChanged,
        style: TextStyle(color: colors.text),
        decoration: InputDecoration(
          hintText: 'Buscar productos...',
          hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, color: colors.primary),
          suffixIcon:
              _query.isNotEmpty
                  ? IconButton(
                    icon: Icon(Icons.clear, color: colors.text),
                    onPressed: () => _onSearchChanged(''),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildFilters(NeumorphicColors colors) {
    final activeCount = [
      _selectedCategoria,
      _selectedSubcategoria,
      _selectedUso,
    ].where((e) => e != null).length;

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _filterChip(
            colors,
            icon: Icons.tune_rounded,
            label: 'Filtros',
            badge: activeCount > 0 ? activeCount : null,
            onTap: activeCount > 0 ? _clearFilters : null,
          ),
          const SizedBox(width: 10),
          _filterChip(
            colors,
            label: _selectedCategoria ?? 'Categoría',
            filled: _selectedCategoria != null,
            onTap: () => _showOptions(
              'Categorías',
              _categorias,
              _selectedCategoria,
              (v) => setState(() => _selectedCategoria = v),
            ),
          ),
          const SizedBox(width: 10),
          _filterChip(
            colors,
            label: _selectedSubcategoria ?? 'Subcategoría',
            filled: _selectedSubcategoria != null,
            onTap: () => _showOptions(
              'Subcategorías',
              _subcategorias,
              _selectedSubcategoria,
              (v) => setState(() => _selectedSubcategoria = v),
            ),
          ),
          const SizedBox(width: 10),
          _filterChip(
            colors,
            label: _selectedUso ?? 'Uso',
            filled: _selectedUso != null,
            onTap: () => _showOptions(
              'Usos',
              _usos,
              _selectedUso,
              (v) => setState(() => _selectedUso = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    NeumorphicColors colors, {
    IconData? icon,
    required String label,
    bool filled = false,
    int? badge,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: filled ? colors.primary : colors.text.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: filled
              ? null
              : Border.all(color: colors.text.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: filled ? Colors.white : colors.text.withValues(alpha: 0.65)),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : colors.text.withValues(alpha: 0.75),
              ),
            ),
            if (icon == null) ...[
              const SizedBox(width: 2),
              Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: filled ? Colors.white : colors.text.withValues(alpha: 0.5)),
            ],
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: colors.secondary, borderRadius: BorderRadius.circular(10)),
                child: Text('$badge', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(NeumorphicColors colors) {
    return Row(
      children: [
        Icon(Icons.inventory_2, color: colors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos encontrados',
              style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
            ),
            Text(
              '${_allMatches.length} resultados • Página $_currentPage de $_totalPages',
              style: TextStyle(
                fontSize: 12,
                color: colors.text.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  SliverGrid _buildGrid(List<ProductoPreview> items) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final p = items[index];
        return ProductGridCard(
          producto: p,
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(productoPreview: p),
                ),
              ),
        );
      }, childCount: items.length),
    );
  }

  Widget _empty(NeumorphicColors colors) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 72, color: colors.text.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No se encontraron productos',
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
          ),
          Text(
            'Intenta cambiar filtros o búsqueda',
            style: TextStyle(color: colors.text.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }

  // ─────────────────── BOTTOM SHEET ───────────────────

  void _showOptions(
    String title,
    List<String> options,
    String? selected,
    Function(String?) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: NeumorphicStyle.elevated(colors),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const SizedBox(height: 12),
              ...options.map(
                (e) => ListTile(
                  title: Text(e, style: TextStyle(color: colors.text)),
                  trailing:
                      selected == e
                          ? Icon(Icons.check, color: colors.primary)
                          : null,
                  onTap: () {
                    onSelect(e);
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: const Text('Todos'),
                onTap: () {
                  onSelect(null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────── API ───────────────────

  Future<void> _cargarProductos() async {
    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final lista = await ProductoService.getCatalogo();
      if (!mounted) return;
      setState(() { _productos = lista; _isLoading = false; });
      _animationController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() { _isLoading = false; _errorMsg = e.toString(); });
    }
  }
}
