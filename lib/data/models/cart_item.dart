import 'dart:convert';

class CartItem {
  final int idProducto;
  final int idPresentacion;
  final String nombreProducto;
  final String? imagenUrl;
  final String unidad;
  final String tamano;       // descripción: "50 kg", "suelto", ""
  final double precioUnitario;
  final double? precioEfectivo;
  int cantidad;              // cantidad comprada

  CartItem({
    required this.idProducto,
    required this.idPresentacion,
    required this.nombreProducto,
    this.imagenUrl,
    required this.unidad,
    required this.tamano,
    required this.precioUnitario,
    this.precioEfectivo,
    required this.cantidad,
  });

  double get subtotal => (precioEfectivo ?? precioUnitario) * cantidad;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // tamano puede ser int (versión vieja) o String (versión nueva)
    final rawTamano = json['tamano'];
    final tamano = rawTamano is num ? rawTamano.toString() : (rawTamano as String? ?? '');
    return CartItem(
      idProducto: json['idProducto'] as int,
      idPresentacion: json['idPresentacion'] as int? ?? 0,
      nombreProducto: json['nombreProducto'] as String,
      imagenUrl: json['imagenUrl'] as String?,
      unidad: json['unidad'] as String,
      tamano: tamano,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      precioEfectivo: json['precioEfectivo'] != null
          ? (json['precioEfectivo'] as num).toDouble()
          : null,
      cantidad: json['cantidad'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'idPresentacion': idPresentacion,
    'nombreProducto': nombreProducto,
    'imagenUrl': imagenUrl,
    'unidad': unidad,
    'tamano': tamano,
    'precioUnitario': precioUnitario,
    'precioEfectivo': precioEfectivo,
    'cantidad': cantidad,
  };

  static String encodeList(List<CartItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<CartItem> decodeList(String source) {
    final List parsed = jsonDecode(source);
    return parsed.map((m) => CartItem.fromJson(m)).toList();
  }
}
