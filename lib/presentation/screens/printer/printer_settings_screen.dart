import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/venta_ticket.dart';
import 'package:forra_store/data/services/printer_service.dart';
import 'package:forra_store/presentation/providers/printer_provider.dart';

class PrinterSettingsScreen extends StatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrinterProvider>().refreshPairedDevices();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final printer = context.watch<PrinterProvider>();

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('Impresora térmica', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        backgroundColor: colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.text),
      ),
      body: RefreshIndicator(
        onRefresh: () => context.read<PrinterProvider>().refreshPairedDevices(),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildEstado(colors, printer),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Impresoras vinculadas', style: TextStyle(fontWeight: FontWeight.bold, color: colors.text, fontSize: 15)),
                const Spacer(),
                if (printer.isScanning)
                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary))
                else
                  IconButton(
                    icon: Icon(Icons.refresh, color: colors.primary, size: 20),
                    onPressed: () => context.read<PrinterProvider>().refreshPairedDevices(),
                  ),
              ],
            ),
            Text(
              'Empareja tu impresora MP210 desde los ajustes de Bluetooth de tu teléfono; luego selecciónala aquí.',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            if (printer.pairedDevices.isEmpty && !printer.isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Sin impresoras vinculadas todavía', style: TextStyle(color: colors.textSecondary, fontSize: 13)),
                ),
              )
            else
              ...printer.pairedDevices.map((d) => _buildDeviceTile(colors, printer, d)),
          ],
        ),
      ),
    );
  }

  Widget _buildEstado(NeumorphicColors colors, PrinterProvider printer) {
    final conectado = printer.isConnected;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: NeumorphicStyle.elevated(colors, radius: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (conectado ? colors.primary : colors.textSecondary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              conectado ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: conectado ? colors.primary : colors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conectado ? printer.connectedDevice!.nombre : 'Sin impresora conectada',
                  style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                ),
                Text(
                  conectado ? 'Lista para imprimir tickets' : 'Conecta una impresora para imprimir tickets',
                  style: TextStyle(fontSize: 11, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (conectado) ...[
            IconButton(
              tooltip: 'Imprimir ticket de prueba',
              icon: Icon(Icons.receipt_long_outlined, color: colors.primary),
              onPressed: printer.isPrinting ? null : () => _imprimirPrueba(context),
            ),
            IconButton(
              tooltip: 'Desconectar',
              icon: Icon(Icons.link_off, color: colors.secondary),
              onPressed: () => context.read<PrinterProvider>().disconnect(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeviceTile(NeumorphicColors colors, PrinterProvider printer, PrinterDevice device) {
    final esLaConectada = printer.connectedDevice?.macAddress == device.macAddress;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: NeumorphicStyle.inset(colors, radius: 12),
      child: Row(
        children: [
          Icon(Icons.print_outlined, color: esLaConectada ? colors.primary : colors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.nombre, style: TextStyle(color: colors.text, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(device.macAddress, style: TextStyle(color: colors.textSecondary, fontSize: 10)),
              ],
            ),
          ),
          if (esLaConectada)
            Icon(Icons.check_circle, color: colors.primary, size: 20)
          else
            TextButton(
              onPressed: printer.isConnecting ? null : () => _conectar(context, device),
              child: Text('Conectar', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Future<void> _conectar(BuildContext context, PrinterDevice device) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await context.read<PrinterProvider>().connect(device);
    if (!ok && context.mounted) {
      messenger.showSnackBar(SnackBar(content: Text(context.read<PrinterProvider>().error ?? 'No se pudo conectar')));
    }
  }

  Future<void> _imprimirPrueba(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final ticket = VentaTicket(
      idVenta: 0,
      fecha: DateTime.now(),
      vendedor: 'Prueba',
      cliente: null,
      items: [
        VentaTicketItem(
          nombreProducto: 'Producto de prueba',
          unidad: 'Pieza',
          tamano: '',
          cantidad: 1,
          precioUnitario: 10.0,
          precioEfectivo: 10.0,
        ),
      ],
      totalOriginal: 10.0,
      descuento: 0,
      totalFinal: 10.0,
    );
    try {
      await context.read<PrinterProvider>().printVenta(ticket);
    } catch (e) {
      if (context.mounted) messenger.showSnackBar(SnackBar(content: Text('No se pudo imprimir: $e')));
    }
  }
}
