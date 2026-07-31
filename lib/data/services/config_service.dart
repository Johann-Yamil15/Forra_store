import 'package:forra_store/data/services/api_client.dart';

class ConfigService {
  static Future<List<String>> getCategorias() async {
    final data = await ApiClient.get('/api/config/categorias') as List;
    return data.cast<String>();
  }

  static Future<void> addCategoria(String nombre) async {
    await ApiClient.post('/api/config/categorias', {'nombre': nombre});
  }

  static Future<List<String>> getSubcategorias() async {
    final data = await ApiClient.get('/api/config/subcategorias') as List;
    return data.cast<String>();
  }

  static Future<void> addSubcategoria(String nombre) async {
    await ApiClient.post('/api/config/subcategorias', {'nombre': nombre});
  }

  static Future<List<String>> getUnidades() async {
    final data = await ApiClient.get('/api/config/unidades') as List;
    return data.cast<String>();
  }

  static Future<void> addUnidad(String nombre) async {
    await ApiClient.post('/api/config/unidades', {'nombre': nombre});
  }
}
