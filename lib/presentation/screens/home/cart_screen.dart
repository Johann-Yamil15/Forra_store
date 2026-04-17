import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:forra_store/presentation/providers/cart_provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/cart_item.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final cartProvider = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Expanded(
            child: cartProvider.items.isEmpty
                ? _buildEmptyCart(colors)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return _CartItemTile(item: item, colors: colors);
                    },
                  ),
          ),
          if (cartProvider.items.isNotEmpty) _buildCheckoutSection(cartProvider, colors),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: NeumorphicStyle.elevated(colors, radius: 100),
            child: Icon(Icons.shopping_cart_outlined, size: 64, color: colors.text.withOpacity(0.3)),
          ),
          const SizedBox(height: 24),
          Text(
            'Tu carrito está vacío',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.text.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutSection(CartProvider cartProvider, NeumorphicColors colors) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: NeumorphicStyle.elevated(colors, radius: 30, depth: 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                Text(
                  '\$${cartProvider.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                // Acción de finalizar compra
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: NeumorphicStyle.elevated(colors, radius: 16).copyWith(
                  color: colors.primary,
                ),
                child: const Center(
                  child: Text(
                    'Finalizar Compra',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final NeumorphicColors colors;

  const _CartItemTile({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: NeumorphicStyle.elevated(colors),
      child: Row(
        children: [
          // Imagen o Icono
          Container(
            width: 70,
            height: 70,
            decoration: NeumorphicStyle.inset(colors, radius: 12),
            child: Icon(Icons.inventory_2_outlined, color: colors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          // Info del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreProducto,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.tamano} ${item.unidad} • \$${item.precioUnitario.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.text.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      colors: colors,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<CartProvider>().updateQuantity(item, item.cantidad - 1);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.cantidad}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.text,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      colors: colors,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        context.read<CartProvider>().updateQuantity(item, item.cantidad + 1);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Eliminar
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              context.read<CartProvider>().removeItem(item);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: NeumorphicStyle.elevated(colors, radius: 10),
              child: Icon(Icons.delete_outline, color: colors.secondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final NeumorphicColors colors;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: NeumorphicStyle.elevated(colors, radius: 8, depth: 3),
        child: Icon(icon, size: 18, color: colors.primary),
      ),
    );
  }
}
