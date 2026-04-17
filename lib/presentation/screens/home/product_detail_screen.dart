import 'package:flutter/material.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/cart_item.dart';
import 'package:forra_store/data/models/producto_preview.dart';
import 'package:forra_store/presentation/providers/cart_provider.dart';
import 'package:forra_store/presentation/widgets/neumorphic_button.dart';
import 'package:forra_store/presentation/widgets/product_card.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductoPreview productoPreview;

  const ProductDetailScreen({super.key, required this.productoPreview});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late final List<PresentacionProducto> _presentaciones;
  PresentacionProducto? _selected;
  int _cantidad = 1;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _presentaciones = widget.productoPreview.presentaciones;
    if (_presentaciones.isNotEmpty) {
      _selected = _presentaciones.first;
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (_selected == null) return;

    if (_selected!.stock < _cantidad) {
      _showSnack(
        icon: Icons.error_outline,
        text: 'Cantidad mayor al stock disponible',
        isError: true,
      );
      return;
    }

    Provider.of<CartProvider>(context, listen: false).addItem(
      CartItem(
        idProducto: widget.productoPreview.idProducto,
        nombreProducto: widget.productoPreview.nombreProducto,
        imagenUrl: widget.productoPreview.imagenUrl,
        unidad: _selected!.unidad,
        tamano: _selected!.tamano,
        precioUnitario: _selected!.precio,
        cantidad: _cantidad,
      ),
    );

    _showSnack(
      icon: Icons.check_circle_outline,
      text:
          'Añadido: ${widget.productoPreview.nombreProducto} '
          '${_selected!.unidad} ${_selected!.tamano} x$_cantidad',
    );
  }

  void _showSnack({
    required IconData icon,
    required String text,
    bool isError = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isError ? colors.primary : colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    final p = widget.productoPreview;

    return Scaffold(
      backgroundColor: colors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: colors.background,
              flexibleSpace: FlexibleSpaceBar(
                background:
                    p.imagenUrl.isNotEmpty
                        ? Image.network(p.imagenUrl, fit: BoxFit.cover)
                        : Container(
                          color: colors.background,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: colors.text.withOpacity(0.7),
                          ),
                        ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(p: p, colors: colors),
                    const SizedBox(height: 24),

                    _Description(p: p, colors: colors),
                    const SizedBox(height: 24),

                    ProductCard(
                      presentaciones: _presentaciones,
                      selected: _selected,
                      onSelected: (pres) {
                        setState(() {
                          _selected = pres;
                          _cantidad = 1;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    if (_selected != null)
                      _CartSection(
                        selected: _selected!,
                        cantidad: _cantidad,
                        colors: colors,
                        onMinus: () {
                          if (_cantidad > 1) {
                            setState(() => _cantidad--);
                          }
                        },
                        onPlus: () {
                          setState(() => _cantidad++);
                        },
                        onAdd: _addToCart,
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
}

/* ──────────────────── SUB WIDGETS ─────────────────── */

class _Header extends StatelessWidget {
  final ProductoPreview p;
  final NeumorphicColors colors;

  const _Header({required this.p, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          p.nombreProducto,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${p.categoria} • ${p.subcategoria} • ${p.uso}',
          style: TextStyle(color: colors.text.withOpacity(0.7)),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  final ProductoPreview p;
  final NeumorphicColors colors;

  const _Description({required this.p, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: NeumorphicStyle.elevated(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            p.descripcionProducto,
            style: TextStyle(color: colors.text.withOpacity(0.7), height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _CartSection extends StatelessWidget {
  final PresentacionProducto selected;
  final int cantidad;
  final NeumorphicColors colors;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final VoidCallback onAdd;

  const _CartSection({
    required this.selected,
    required this.cantidad,
    required this.colors,
    required this.onMinus,
    required this.onPlus,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = selected.precio * cantidad;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: NeumorphicStyle.elevated(colors),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ───── HEADER ─────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: NeumorphicStyle.inset(colors),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 20,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Producto seleccionado',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colors.text,
                      ),
                    ),
                    Text(
                      '${selected.unidad} ${selected.tamano}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ───── PRECIO ─────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: NeumorphicStyle.inset(colors),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precio unitario',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${selected.precio.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          /// ───── CANTIDAD ─────
          Row(
            children: [
              Text(
                'Cantidad:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colors.text,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: NeumorphicStyle.inset(colors),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: onMinus,
                      colors: colors,
                      disabled: cantidad <= 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      child: Text(
                        '$cantidad',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ),
                    _QtyButton(icon: Icons.add, onTap: onPlus, colors: colors),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          /// ───── BOTÓN ─────
          SizedBox(
            width: double.infinity,
            height: 56,
            child: NeumorphicButton(
              text: 'Agregar al carrito',
              icon: Icons.add_shopping_cart,
              onTap: onAdd,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final NeumorphicColors colors;
  final bool disabled;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.colors,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: NeumorphicStyle.elevated(colors),
        child: Icon(
          icon,
          size: 20,
          color: disabled ? colors.text.withOpacity(0.4) : colors.primary,
        ),
      ),
    );
  }
}
