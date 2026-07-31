import 'dart:convert';
import 'package:forra_store/data/models/cart_item.dart';

class Pedido {
  final String id;
  final DateTime fecha;
  final int? idCliente;
  final String nombreCliente;
  final double totalOriginal;
  final double descuento;
  final double totalFinal;
  final List<CartItem> items;

  Pedido({
    required this.id,
    required this.fecha,
    this.idCliente,
    required this.nombreCliente,
    required this.totalOriginal,
    required this.descuento,
    required this.totalFinal,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fecha': fecha.toIso8601String(),
      'idCliente': idCliente,
      'nombreCliente': nombreCliente,
      'totalOriginal': totalOriginal,
      'descuento': descuento,
      'totalFinal': totalFinal,
      'items': items.map((x) => x.toJson()).toList(),
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'] ?? '',
      fecha: DateTime.parse(map['fecha']),
      idCliente: map['idCliente'],
      nombreCliente: map['nombreCliente'] ?? '',
      totalOriginal: (map['totalOriginal'] as num).toDouble(),
      descuento: (map['descuento'] as num).toDouble(),
      totalFinal: (map['totalFinal'] as num).toDouble(),
      items: List<CartItem>.from(map['items']?.map((x) => CartItem.fromJson(x as Map<String, dynamic>))),
    );
  }

  String toJson() => json.encode(toMap());

  factory Pedido.fromJson(String source) => Pedido.fromMap(json.decode(source));

  static String encodeList(List<Pedido> pedidos) {
    return json.encode(pedidos.map((p) => p.toMap()).toList());
  }

  static List<Pedido> decodeList(String source) {
    final List<dynamic> decoded = json.decode(source);
    return decoded.map((item) => Pedido.fromMap(item)).toList();
  }
}
