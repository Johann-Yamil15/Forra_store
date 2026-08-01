class ApiConstants {
  // API .NET 9 + PostgreSQL desplegada en Railway.
  static const String baseUrl = 'https://forracontrol-api-production.up.railway.app';

  static const Duration timeout = Duration(seconds: 20);

  /// Las imágenes de productos subidas desde la app vienen como ruta relativa
  /// (ej. "/uploads/productos/xxx.jpg"); las URLs externas antiguas siguen
  /// siendo absolutas. Esto normaliza ambos casos para Image.network.
  static String resolveImageUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl$path';
  }
}
