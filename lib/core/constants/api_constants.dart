class ApiConstants {
  // API .NET 9 + PostgreSQL desplegada en Railway.
  static const String baseUrl = 'https://forracontrol-api-production-2a53.up.railway.app';

  // Railway duerme el servicio tras estar inactivo; despertarlo puede tardar
  // más de 20s, así que el timeout necesita margen para no cortar esa espera.
  static const Duration timeout = Duration(seconds: 45);

  /// Las imágenes de productos subidas desde la app vienen como ruta relativa
  /// (ej. "/uploads/productos/xxx.jpg"); las URLs externas antiguas siguen
  /// siendo absolutas. Esto normaliza ambos casos para Image.network.
  static String resolveImageUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl$path';
  }
}
