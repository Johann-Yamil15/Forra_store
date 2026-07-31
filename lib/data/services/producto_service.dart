import 'package:forra_store/data/models/producto_preview.dart';
import 'package:forra_store/data/services/api_client.dart';

class ProductoService {
  static Future<List<ProductoPreview>> getCatalogo() async {
    final data = await ApiClient.get('/api/productos') as List;
    return data.map((j) => ProductoPreview.fromJson(j as Map<String, dynamic>)).toList();
  }
}
