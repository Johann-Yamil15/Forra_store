import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forra_store/presentation/providers/pedidos_provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/screens/home/pedido_detail_screen.dart';
import 'package:intl/intl.dart';

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final pedidosProvider = context.watch<PedidosProvider>();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      backgroundColor: colors.background,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
            child: Row(
              children: [
                Text(
                  'Historial de Pedidos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${pedidosProvider.pedidos.length} ventas',
                    style: TextStyle(color: colors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pedidosProvider.pedidos.isEmpty
                ? _buildEmptyState(colors)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    itemCount: pedidosProvider.pedidos.length,
                    itemBuilder: (context, index) {
                      final pedido = pedidosProvider.pedidos[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PedidoDetailScreen(pedido: pedido),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: NeumorphicStyle.elevated(colors, radius: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    dateFormat.format(pedido.fecha),
                                    style: TextStyle(
                                      color: colors.text.withValues(alpha: 0.5),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '\$${pedido.totalFinal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: colors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                pedido.nombreCliente,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: colors.text,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pedido.items.length} productos • Finalizado',
                                style: TextStyle(
                                  color: colors.text.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(NeumorphicColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 80, color: colors.text.withValues(alpha: 0.1)),
          const SizedBox(height: 24),
          Text(
            'Aún no hay pedidos realizados',
            style: TextStyle(color: colors.text.withValues(alpha: 0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
