import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterDevice {
  final String nombre;
  final String macAddress;
  const PrinterDevice({required this.nombre, required this.macAddress});
}

/// Envoltura sobre print_bluetooth_thermal: vinculación, conexión y envío de
/// bytes ESC/POS a la impresora térmica (MP210, 58 mm, Bluetooth clásico).
class PrinterService {
  static const _prefMac = 'printer_mac_v1';
  static const _prefNombre = 'printer_nombre_v1';

  static Future<bool> bluetoothEnabled() => PrintBluetoothThermal.bluetoothEnabled;

  /// Android 12+ requiere estos permisos en tiempo de ejecución además de
  /// declararlos en el manifest; en versiones anteriores no hacen nada.
  static Future<bool> solicitarPermisos() async {
    final estados = await [Permission.bluetoothConnect, Permission.bluetoothScan].request();
    return estados.values.every((s) => s.isGranted);
  }

  /// Impresoras ya vinculadas por el sistema (el emparejamiento inicial se
  /// hace desde los ajustes de Bluetooth de Android, no desde la app).
  static Future<List<PrinterDevice>> pairedDevices() async {
    final result = await PrintBluetoothThermal.pairedBluetooths;
    return result.map((d) => PrinterDevice(nombre: d.name, macAddress: d.macAdress)).toList();
  }

  static Future<bool> connect(String macAddress) =>
      PrintBluetoothThermal.connect(macPrinterAddress: macAddress);

  static Future<bool> get connectionStatus => PrintBluetoothThermal.connectionStatus;

  static Future<void> disconnect() => PrintBluetoothThermal.disconnect;

  static Future<bool> printBytes(List<int> bytes) => PrintBluetoothThermal.writeBytes(bytes);

  /// Recuerda la última impresora conectada para reconectar sola al abrir la app.
  static Future<void> guardarUltimaImpresora(PrinterDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefMac, device.macAddress);
    await prefs.setString(_prefNombre, device.nombre);
  }

  static Future<PrinterDevice?> ultimaImpresoraGuardada() async {
    final prefs = await SharedPreferences.getInstance();
    final mac = prefs.getString(_prefMac);
    final nombre = prefs.getString(_prefNombre);
    if (mac == null) return null;
    return PrinterDevice(nombre: nombre ?? mac, macAddress: mac);
  }

  static Future<void> olvidarImpresora() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefMac);
    await prefs.remove(_prefNombre);
  }
}
