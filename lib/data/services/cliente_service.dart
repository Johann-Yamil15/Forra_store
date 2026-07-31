import 'package:forra_store/data/models/cliente.dart';
import 'package:forra_store/data/services/api_client.dart';

class ClienteService {
  static Future<List<Cliente>> getClientes() async {
    final data = await ApiClient.get('/api/clientes') as List;
    return data.map((j) => Cliente.fromJson(j as Map<String, dynamic>)).toList();
  }
}
