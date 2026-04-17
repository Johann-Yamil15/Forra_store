import 'package:flutter/material.dart';
import 'package:forra_store/data/models/producto_preview.dart';
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
  late List<ProductoPreview> _productos;

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

    _cargarProductosMock();
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
          hintStyle: TextStyle(color: colors.text.withOpacity(0.5)),
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
    final active =
        _selectedCategoria != null ||
        _selectedSubcategoria != null ||
        _selectedUso != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeumorphicStyle.elevated(colors, radius: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
              const Spacer(),
              if (active)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Limpiar'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _chip(
                  colors,
                  _selectedCategoria ?? 'Categoría',
                  _selectedCategoria != null,
                  () => _showOptions(
                    'Categorías',
                    _categorias,
                    _selectedCategoria,
                    (v) => setState(() => _selectedCategoria = v),
                  ),
                ),
                const SizedBox(width: 8),
                _chip(
                  colors,
                  _selectedSubcategoria ?? 'Subcategoría',
                  _selectedSubcategoria != null,
                  () => _showOptions(
                    'Subcategorías',
                    _subcategorias,
                    _selectedSubcategoria,
                    (v) => setState(() => _selectedSubcategoria = v),
                  ),
                ),
                const SizedBox(width: 8),
                _chip(
                  colors,
                  _selectedUso ?? 'Uso',
                  _selectedUso != null,
                  () => _showOptions(
                    'Usos',
                    _usos,
                    _selectedUso,
                    (v) => setState(() => _selectedUso = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(
    NeumorphicColors colors,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration:
            selected
                ? NeumorphicStyle.inset(colors)
                : NeumorphicStyle.elevated(colors),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: colors.text)),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: colors.text),
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
                color: colors.text.withOpacity(0.6),
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
          Icon(Icons.search_off, size: 72, color: colors.text.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            'No se encontraron productos',
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
          ),
          Text(
            'Intenta cambiar filtros o búsqueda',
            style: TextStyle(color: colors.text.withOpacity(0.6)),
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

  // ─────────────────── MOCK ───────────────────

  void _cargarProductosMock() {
    setState(() {
      _productos = _mockProductos();
    });

    _animationController.forward();
  }

  List<ProductoPreview> _mockProductos() {
    return [
      ProductoPreview(
        idProducto: 1,
        nombreProducto: "Maíz Amarillo",
        descripcionProducto: "Maíz de alta calidad",
        categoria: "Granos",
        subcategoria: "Maíz",
        uso: "Alimento",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/maiz.jpg",
        presentaciones: [
          PresentacionProducto(unidad: "Kg", tamano: 1, precio: 50, stock: 100),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 20,
            precio: 250,
            stock: 100,
          ),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 40,
            precio: 380,
            stock: 100,
          ),
        ],
      ),
      // 🔹 el resto EXACTAMENTE como lo tienes
      ProductoPreview(
        idProducto: 2,
        nombreProducto: "Alimento de Puerco 30/70",
        descripcionProducto:
            "Alimento balanceado para cerdos con 30% proteína y 70% carbohidratos.",
        categoria: "Alimentos",
        subcategoria: "Puerco",
        uso: "Nutrición animal",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/alimento_puerco.jpg",
        presentaciones: [
          PresentacionProducto(unidad: "Kg", tamano: 1, precio: 45, stock: 200),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 25,
            precio: 850,
            stock: 80,
          ),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 40,
            precio: 1200,
            stock: 60,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 3,
        nombreProducto: "Alimento para Perro",
        descripcionProducto:
            "Croquetas premium para perros de todas las edades.",
        categoria: "Alimentos",
        subcategoria: "Perros",
        uso: "Mascotas",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/alimento_perro.jpg",
        presentaciones: [
          PresentacionProducto(unidad: "Kg", tamano: 1, precio: 70, stock: 150),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 20,
            precio: 1200,
            stock: 100,
          ),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 40,
            precio: 2000,
            stock: 50,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 4,
        nombreProducto: "Líquido para Fumigar Folei",
        descripcionProducto:
            "Insecticida agrícola para control de plagas en cultivos.",
        categoria: "Agroquímicos",
        subcategoria: "Insecticidas",
        uso: "Fumigación",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/liquido_fumigar.jpg",
        presentaciones: [
          PresentacionProducto(
            unidad: "Litro",
            tamano: 1,
            precio: 180,
            stock: 90,
          ),
          PresentacionProducto(
            unidad: "Galón",
            tamano: 4,
            precio: 650,
            stock: 50,
          ),
          PresentacionProducto(
            unidad: "Bidón",
            tamano: 20,
            precio: 2800,
            stock: 30,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 5,
        nombreProducto: "Comedero de Pollo",
        descripcionProducto:
            "Comedero plástico resistente para pollos en diferentes tamaños.",
        categoria: "Accesorios",
        subcategoria: "Aves",
        uso: "Equipamiento",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/comedero_pollo.jpg",
        presentaciones: [
          PresentacionProducto(
            unidad: "Pieza ch",
            tamano: 1,
            precio: 120,
            stock: 100,
          ),
          PresentacionProducto(
            unidad: "Pieza med",
            tamano: 1,
            precio: 180,
            stock: 80,
          ),
          PresentacionProducto(
            unidad: "Pieza gra",
            tamano: 1,
            precio: 250,
            stock: 60,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 6,
        nombreProducto: "Líquido para Fumigar Folei",
        descripcionProducto:
            "Insecticida agrícola para control de plagas en cultivos.",
        categoria: "Agroquímicos",
        subcategoria: "Insecticidas",
        uso: "Fumigación",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/liquido_fumigar.jpg",
        presentaciones: [
          PresentacionProducto(
            unidad: "Litro",
            tamano: 1,
            precio: 180,
            stock: 90,
          ),
          PresentacionProducto(
            unidad: "Galón",
            tamano: 4,
            precio: 650,
            stock: 50,
          ),
          PresentacionProducto(
            unidad: "Bidón",
            tamano: 20,
            precio: 2800,
            stock: 30,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 7,
        nombreProducto: "Alimento de Puerco 30/70",
        descripcionProducto:
            "Alimento balanceado para cerdos con 30% proteína y 70% carbohidratos.",
        categoria: "Alimentos",
        subcategoria: "Puerco",
        uso: "Nutrición animal",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/alimento_puerco.jpg",
        presentaciones: [
          PresentacionProducto(unidad: "Kg", tamano: 1, precio: 45, stock: 200),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 25,
            precio: 850,
            stock: 80,
          ),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 40,
            precio: 1200,
            stock: 60,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 8,
        nombreProducto: "Alimento para Perro",
        descripcionProducto:
            "Croquetas premium para perros de todas las edades.",
        categoria: "Alimentos",
        subcategoria: "Perros",
        uso: "Mascotas",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/alimento_perro.jpg",
        presentaciones: [
          PresentacionProducto(unidad: "Kg", tamano: 1, precio: 70, stock: 150),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 20,
            precio: 1200,
            stock: 100,
          ),
          PresentacionProducto(
            unidad: "Bulto",
            tamano: 40,
            precio: 2000,
            stock: 50,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 9,
        nombreProducto: "Líquido para Fumigar Folei",
        descripcionProducto:
            "Insecticida agrícola para control de plagas en cultivos.",
        categoria: "Agroquímicos",
        subcategoria: "Insecticidas",
        uso: "Fumigación",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/liquido_fumigar.jpg",
        presentaciones: [
          PresentacionProducto(
            unidad: "Litro",
            tamano: 1,
            precio: 180,
            stock: 90,
          ),
          PresentacionProducto(
            unidad: "Galón",
            tamano: 4,
            precio: 650,
            stock: 50,
          ),
          PresentacionProducto(
            unidad: "Bidón",
            tamano: 20,
            precio: 2800,
            stock: 30,
          ),
        ],
      ),
      ProductoPreview(
        idProducto: 10,
        nombreProducto: "Comedero de Pollo",
        descripcionProducto:
            "Comedero plástico resistente para pollos en diferentes tamaños.",
        categoria: "Accesorios",
        subcategoria: "Aves",
        uso: "Equipamiento",
        imagenUrl:
            "https://delagarzamateriasprimas.com/wp-content/uploads/2024/07/comedero_pollo.jpg",
        presentaciones: [
          PresentacionProducto(
            unidad: "Pieza ch",
            tamano: 1,
            precio: 120,
            stock: 100,
          ),
          PresentacionProducto(
            unidad: "Pieza med",
            tamano: 1,
            precio: 180,
            stock: 80,
          ),
          PresentacionProducto(
            unidad: "Pieza gra",
            tamano: 1,
            precio: 250,
            stock: 60,
          ),
        ],
      ),
    ];
  }
}
