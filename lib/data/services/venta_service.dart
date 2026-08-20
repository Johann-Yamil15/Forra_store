import 'package:forra_store/data/models/cart_item.dart';
import 'package:forra_store/data/models/pedido.dart';
import 'package:forra_store/data/services/api_client.dart';

class VentaService {
  /// Registra la venta en el servidor.
  /// Devuelve el idVenta asignado por el servidor.
  static Future<int> crearVenta({
    required int idUsuario,
    required int? idCliente,
    required double totalOriginal,
    required double descuento,
    required double totalFinal,
    required List<CartItem> items,
  }) async {
    final data = await ApiClient.post('/api/ventas', {
      'idUsuario': idUsuario,
      'idCliente': idCliente,
      'totalOriginal': totalOriginal,
      'descuento': descuento,
      'totalFinal': totalFinal,
      'items': items.map((it) => {
        'idProducto': it.idProducto,
        'idPresentacion': it.idPresentacion,
        'nombreProducto': it.nombreProducto,
        'unidad': it.unidad,
        'tamano': it.tamano,
        'cantidad': it.cantidad,
        'precioUnitario': it.precioUnitario,
        'precioEfectivo': it.precioEfectivo ?? it.precioUnitario,
        'subtotal': it.subtotal,
      }).toList(),
    });
    return (data as Map<String, dynamic>)['idVenta'] as int;
  }

  /// Carga el historial de ventas desde el servidor.
  static Future<List<Pedido>> getVentas({int? idUsuario, String? periodo}) async {
    final params = <String, String>{};
    if (idUsuario != null) params['idUsuario'] = '$idUsuario';
    if (periodo != null) params['periodo'] = periodo;
    final query = params.isEmpty ? '' : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final data = await ApiClient.get('/api/ventas$query') as List;
    return data.map((j) => Pedido.fromMap(j as Map<String, dynamic>)).toList();
  }

  /// Carga el detalle completo (con items) de una venta puntual.
  static Future<Pedido> getVentaDetalle(int idVenta) async {
    final data = await ApiClient.get('/api/ventas/$idVenta') as Map<String, dynamic>;
    return Pedido.fromMap(data);
  }
}
