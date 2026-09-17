import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/data/models/venta_ticket.dart';
import 'package:forra_store/data/services/printer_service.dart';
import 'package:forra_store/data/services/ticket_formatter.dart';
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _mostrarVistaPrevia(context),
                icon: Icon(Icons.visibility_outlined, color: colors.primary),
                label: Text('Vista previa del ticket', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
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

  /// Venta ficticia con varios artículos (uno con precio especial) para que
  /// tanto la vista previa como el ticket de prueba muestren un caso real,
  /// no un ticket vacío de un solo producto.
  VentaTicket _ticketDeEjemplo() {
    final items = [
      VentaTicketItem(
        nombreProducto: 'Alimento Purina Ganado',
        unidad: 'Bulto',
        tamano: '40 kg',
        cantidad: 2,
        precioUnitario: 350.0,
        precioEfectivo: 320.0,
      ),
      VentaTicketItem(
        nombreProducto: 'Alambre de Puas',
        unidad: 'Rollo',
        tamano: '',
        cantidad: 1,
        precioUnitario: 890.0,
        precioEfectivo: 890.0,
      ),
      VentaTicketItem(
        nombreProducto: 'Vitaminas Vigor',
        unidad: 'Frasco',
        tamano: '500 ml',
        cantidad: 3,
        precioUnitario: 145.5,
        precioEfectivo: 145.5,
      ),
    ];
    final totalOriginal = items.fold(0.0, (s, i) => s + i.precioUnitario * i.cantidad);
    final totalFinal = items.fold(0.0, (s, i) => s + i.subtotal);
    return VentaTicket(
      idVenta: 123,
      fecha: DateTime.now(),
      vendedor: 'Trabajador Demo',
      cliente: 'Juan Perez',
      items: items,
      totalOriginal: totalOriginal,
      descuento: totalOriginal - totalFinal,
      totalFinal: totalFinal,
    );
  }

  void _mostrarVistaPrevia(BuildContext context) {
    final lineas = TicketFormatter.previewLines(_ticketDeEjemplo());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Container(
                width: 300,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: lineas
                        .map((l) => Text(
                              l.texto.isEmpty ? ' ' : l.texto,
                              textAlign: l.align == TicketAlign.center ? TextAlign.center : TextAlign.left,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11.5,
                                height: 1.35,
                                fontWeight: l.bold ? FontWeight.bold : FontWeight.normal,
                                color: Colors.black,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _imprimirPrueba(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<PrinterProvider>().printVenta(_ticketDeEjemplo());
    } catch (e) {
      if (context.mounted) messenger.showSnackBar(SnackBar(content: Text('No se pudo imprimir: $e')));
    }
  }
}
