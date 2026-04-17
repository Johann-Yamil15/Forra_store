import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:forra_store/presentation/providers/cart_provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/cart_item.dart';
import 'package:forra_store/data/models/cliente.dart';

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
          _buildCustomerSelector(context, cartProvider, colors),
          Expanded(
            child: cartProvider.items.isEmpty
                ? _buildEmptyCart(colors)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(color: colors.darkShadow.withOpacity(0.15)),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.darkShadow.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal Original (si hay descuento)
            if (cartProvider.totalDescuento > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtotal',
                      style: TextStyle(color: colors.text.withOpacity(0.6)),
                    ),
                    Text(
                      '\$${cartProvider.totalOriginal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.text.withOpacity(0.6),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            // Descuento
            if (cartProvider.totalDescuento > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Descuento Cliente Especial',
                      style: TextStyle(
                        color: colors.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '-\$${cartProvider.totalDescuento.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: colors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total a Pagar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                Text(
                  '\$${cartProvider.totalFinal.toStringAsFixed(2)}',
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

  Widget _buildCustomerSelector(
    BuildContext context,
    CartProvider cartProvider,
    NeumorphicColors colors,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: NeumorphicStyle.elevated(colors, radius: 12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          Icons.person_search_outlined,
          color: colors.primary,
        ),
        title: Text(
          cartProvider.selectedCliente?.nombre ?? 'Seleccionar Cliente',
          style: TextStyle(
            color: cartProvider.selectedCliente != null
                ? colors.text
                : colors.text.withOpacity(0.5),
            fontWeight: cartProvider.selectedCliente != null
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: Icon(Icons.keyboard_arrow_down, color: colors.text.withOpacity(0.5)),
        onTap: () => _showCustomerPicker(context, cartProvider, colors),
      ),
    );
  }

  void _showCustomerPicker(
    BuildContext context,
    CartProvider cartProvider,
    NeumorphicColors colors,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredClientes = cartProvider.mockClientes
                .where((c) => c.nombre.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.text.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Buscar Cliente',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Nombre del cliente...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.darkShadow.withOpacity(0.2)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colors.darkShadow.withOpacity(0.1)),
                      ),
                    ),
                    onChanged: (val) {
                      setModalState(() => searchQuery = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredClientes.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person_off_outlined)),
                            title: const Text('Sin Cliente (Precio Público)'),
                            selected: cartProvider.selectedCliente == null,
                            onTap: () {
                              cartProvider.selectCliente(null);
                              Navigator.pop(context);
                            },
                          );
                        }
                        final cliente = filteredClientes[index - 1];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colors.primary.withOpacity(0.1),
                            child: Text(
                              cliente.nombre[0],
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                          title: Text(cliente.nombre),
                          subtitle: const Text('Comprador Concurrente'),
                          selected: cartProvider.selectedCliente?.id == cliente.id,
                          onTap: () {
                            cartProvider.selectCliente(cliente);
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.tamano} ${item.unidad} • ',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.text.withOpacity(0.6),
                      ),
                    ),
                    if (context.read<CartProvider>().getItemPrice(item) <
                        item.precioUnitario) ...[
                      Text(
                        '\$${item.precioUnitario.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.text.withOpacity(0.4),
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${context.read<CartProvider>().getItemPrice(item).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: colors.secondary,
                        ),
                      ),
                    ] else
                      Text(
                        '\$${item.precioUnitario.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.text,
                        ),
                      ),
                  ],
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
