import 'dart:io';
import 'package:forra_store/data/services/api_client.dart';

// DTOs planos — AdminProvider los convierte a sus propios modelos
class AdminService {
  // ── Catálogo Admin ──────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getProductos() async {
    final data = await ApiClient.get('/api/admin/productos') as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<int> createProducto(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/api/admin/productos', body);
    return (data as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> updateProducto(int id, Map<String, dynamic> body) async {
    await ApiClient.put('/api/admin/productos/$id', body);
  }

  static Future<void> deleteProducto(int id) async {
    await ApiClient.delete('/api/admin/productos/$id');
  }

  // ── Presentaciones ──────────────────────────────────────────────────────────

  static Future<int> addPresentacion(int idProducto, Map<String, dynamic> body) async {
    final data = await ApiClient.post('/api/admin/productos/$idProducto/presentaciones', body);
    return (data as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> updatePresentacion(int id, Map<String, dynamic> body) async {
    await ApiClient.put('/api/admin/presentaciones/$id', body);
  }

  static Future<void> deletePresentacion(int id) async {
    await ApiClient.delete('/api/admin/presentaciones/$id');
  }

  static Future<String> subirImagenProducto(int idProducto, File imagen) async {
    final data = await ApiClient.postFile(
      '/api/admin/productos/$idProducto/imagen',
      fieldName: 'imagen',
      file: imagen,
    );
    return (data as Map<String, dynamic>)['imagenUrl'] as String;
  }

  static Future<int> addStock(int idPresentacion, int cantidad) async {
    final data = await ApiClient.patch(
      '/api/admin/presentaciones/$idPresentacion/stock',
      {'cantidad': cantidad},
    );
    return (data as Map<String, dynamic>)['stockActual'] as int;
  }

  // ── Clientes ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getClientes() async {
    final data = await ApiClient.get('/api/admin/clientes') as List;
    return data.cast<Map<String, dynamic>>();
  }

  static Future<int> createCliente(Map<String, dynamic> body) async {
    final data = await ApiClient.post('/api/admin/clientes', body);
    return (data as Map<String, dynamic>)['id'] as int;
  }

  static Future<void> updateCliente(int id, Map<String, dynamic> body) async {
    await ApiClient.put('/api/admin/clientes/$id', body);
  }

  static Future<void> deleteCliente(int id) async {
    await ApiClient.delete('/api/admin/clientes/$id');
  }

  static Future<void> savePrecios(int idCliente, List<Map<String, dynamic>> precios) async {
    await ApiClient.put('/api/admin/clientes/$idCliente/precios', {'precios': precios});
  }

  // ── Dashboard / Reportes ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getDashboard() async {
    return (await ApiClient.get('/api/admin/dashboard')) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getReportes(String periodo) async {
    return (await ApiClient.get('/api/admin/reportes?periodo=$periodo')) as Map<String, dynamic>;
  }
}
