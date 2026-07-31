class ApiConstants {
  // Android emulator → 10.0.2.2 apunta a localhost de la PC
  // Dispositivo físico → usa la IP LAN de la PC (ej. 192.168.1.x)
  // iOS simulator → localhost funciona directamente
  static const String baseUrl = 'http://10.0.2.2:5255';

  static const Duration timeout = Duration(seconds: 20);
}
