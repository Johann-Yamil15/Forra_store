import 'package:flutter/material.dart';
import 'package:forra_store/data/models/venta_ticket.dart';
import 'package:forra_store/data/services/printer_service.dart';
import 'package:forra_store/data/services/ticket_formatter.dart';

class PrinterProvider extends ChangeNotifier {
  List<PrinterDevice> pairedDevices = [];
  PrinterDevice? connectedDevice;
  bool isScanning = false;
  bool isConnecting = false;
  bool isPrinting = false;
  String? error;

  bool get isConnected => connectedDevice != null;

  PrinterProvider() {
    _autoReconnect();
  }

  /// Al abrir la app, intenta reconectar sola a la última impresora usada
  /// (si el Bluetooth del teléfono sigue emparejado y encendido).
  Future<void> _autoReconnect() async {
    final ultima = await PrinterService.ultimaImpresoraGuardada();
    if (ultima == null) return;
    try {
      if (!await PrinterService.solicitarPermisos()) return;
      final ok = await PrinterService.connect(ultima.macAddress);
      if (ok) {
        connectedDevice = ultima;
        notifyListeners();
      }
    } catch (_) {
      // Sin impresora a la mano todavía — el usuario reconecta manualmente.
    }
  }

  Future<void> refreshPairedDevices() async {
    isScanning = true;
    error = null;
    notifyListeners();
    try {
      final permitido = await PrinterService.solicitarPermisos();
      if (!permitido) {
        error = 'Se necesita permiso de Bluetooth para buscar impresoras';
        return;
      }
      pairedDevices = await PrinterService.pairedDevices();
    } catch (e) {
      error = 'No se pudo buscar impresoras vinculadas: $e';
    } finally {
      isScanning = false;
      notifyListeners();
    }
  }

  Future<bool> connect(PrinterDevice device) async {
    isConnecting = true;
    error = null;
    notifyListeners();
    try {
      final ok = await PrinterService.connect(device.macAddress);
      if (ok) {
        connectedDevice = device;
        await PrinterService.guardarUltimaImpresora(device);
      } else {
        error = 'No se pudo conectar con ${device.nombre}';
      }
      return ok;
    } catch (e) {
      error = 'No se pudo conectar: $e';
      return false;
    } finally {
      isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await PrinterService.disconnect();
    } finally {
      connectedDevice = null;
      notifyListeners();
    }
  }

  Future<void> olvidarImpresora() async {
    await disconnect();
    await PrinterService.olvidarImpresora();
  }

  /// Imprime el ticket de una venta. Lanza si no hay impresora conectada o
  /// si la impresora rechaza los bytes (apagada, sin papel, fuera de rango).
  Future<void> printVenta(VentaTicket venta) async {
    final device = connectedDevice;
    if (device == null) {
      throw Exception('No hay una impresora conectada');
    }
    isPrinting = true;
    notifyListeners();
    try {
      final bytes = await TicketFormatter.build(venta);
      final ok = await PrinterService.printBytes(bytes);
      if (!ok) {
        connectedDevice = null;
        throw Exception('La impresora no respondió (revisa que esté encendida y con papel)');
      }
    } finally {
      isPrinting = false;
      notifyListeners();
    }
  }
}
