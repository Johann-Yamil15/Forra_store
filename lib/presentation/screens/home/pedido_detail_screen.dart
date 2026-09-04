import 'package:flutter/material.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/pedido.dart';
import 'package:intl/intl.dart';

class PedidoDetailScreen extends StatelessWidget {
  final Pedido pedido;

  const PedidoDetailScreen({super.key, required this.pedido});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Detalle de Pedido', style: TextStyle(color: colors.text)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del pedido
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: NeumorphicStyle.elevated(colors, radius: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: #${pedido.id}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Finalizado',
                          style: TextStyle(color: colors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    pedido.nombreCliente,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(pedido.fecha),
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 16),
            ...pedido.items.map((item) => _PedidoItemTile(item: item, colors: colors)),
            const SizedBox(height: 32),
            // Resumen de precios
            Container(
              padding: const EdgeInsets.all(20),
              decoration: NeumorphicStyle.elevated(colors, radius: 16),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Subtotal Original',
                    value: '\$${pedido.totalOriginal.toStringAsFixed(2)}',
                    colors: colors,
                    isStrikethrough: pedido.descuento > 0,
                  ),
                  if (pedido.descuento > 0) ...[
                    const SizedBox(height: 12),
                    _PriceRow(
                      label: 'Descuento Aplicado',
                      value: '-\$${pedido.descuento.toStringAsFixed(2)}',
                      colors: colors,
                      valueColor: colors.secondary,
                    ),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(),
                  ),
                  _PriceRow(
                    label: 'Total Final',
                    value: '\$${pedido.totalFinal.toStringAsFixed(2)}',
                    colors: colors,
                    isTotal: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _PedidoItemTile extends StatelessWidget {
  final dynamic item;
  final NeumorphicColors colors;

  const _PedidoItemTile({required this.item, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.darkShadow.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.inventory_2, color: colors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombreProducto,
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                ),
                Text(
                  '${item.cantidad} x \$${(item.precioEfectivo ?? item.precioUnitario).toStringAsFixed(2)} (${item.unidad})',
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            '\$${(item.cantidad * (item.precioEfectivo ?? item.precioUnitario)).toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final NeumorphicColors colors;
  final bool isTotal;
  final bool isStrikethrough;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.colors,
    this.isTotal = false,
    this.isStrikethrough = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: colors.text.withValues(alpha: isTotal ? 1.0 : 0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 22 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? (isTotal ? colors.primary : colors.text),
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
