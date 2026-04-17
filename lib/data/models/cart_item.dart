// lib/data/models/cart_item.dart
import 'dart:convert';

class CartItem {
  final int idProducto;
  final String nombreProducto;
  final String? imagenUrl;
  final String unidad;
  final int tamano;
  final double precioUnitario;
  int cantidad;

  CartItem({
    required this.idProducto,
    required this.nombreProducto,
    this.imagenUrl,
    required this.unidad,
    required this.tamano,
    required this.precioUnitario,
    required this.cantidad,
  });

  double get subtotal => precioUnitario * cantidad;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      idProducto: json['idProducto'],
      nombreProducto: json['nombreProducto'],
      imagenUrl: json['imagenUrl'],
      unidad: json['unidad'],
      tamano: json['tamano'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      cantidad: json['cantidad'],
    );
  }

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'nombreProducto': nombreProducto,
    'imagenUrl': imagenUrl,
    'unidad': unidad,
    'tamano': tamano,
    'precioUnitario': precioUnitario,
    'cantidad': cantidad,
  };

  static String encodeList(List<CartItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<CartItem> decodeList(String source) {
    final List parsed = jsonDecode(source);
    return parsed.map((m) => CartItem.fromJson(m)).toList();
  }
}
