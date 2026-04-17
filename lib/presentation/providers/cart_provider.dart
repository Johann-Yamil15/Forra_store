// lib/presentation/providers/cart_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:forra_store/data/models/cart_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'cart_items_v1';

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  CartProvider() {
    // carga inicial (no await en constructor; inicia en background)
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = CartItem.decodeList(raw);
        _items.clear();
        _items.addAll(decoded);
        notifyListeners();
      }
    } catch (e) {
      // manejo simple de errores (puedes loggear con NLog o similar)
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, CartItem.encodeList(_items));
  }

  void addItem(CartItem item) {
    // Si ya existe producto (misma presentación), incrementar cantidad
    final index = _items.indexWhere(
      (i) =>
          i.idProducto == item.idProducto &&
          i.unidad == item.unidad &&
          i.tamano == item.tamano,
    );
    if (index >= 0) {
      _items[index].cantidad += item.cantidad;
    } else {
      _items.add(item);
    }
    _saveCart();
    notifyListeners();
  }

  void updateQuantity(CartItem item, int newQty) {
    final index = _items.indexWhere(
      (i) =>
          i.idProducto == item.idProducto &&
          i.unidad == item.unidad &&
          i.tamano == item.tamano,
    );
    if (index >= 0) {
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].cantidad = newQty;
      }
      _saveCart();
      notifyListeners();
    }
  }

  void removeItem(CartItem item) {
    _items.removeWhere(
      (i) =>
          i.idProducto == item.idProducto &&
          i.unidad == item.unidad &&
          i.tamano == item.tamano,
    );
    _saveCart();
    notifyListeners();
  }

  double get total => _items.fold(
    0.0,
    (sum, item) => sum + item.precioUnitario * item.cantidad,
  );

  int get totalItems => _items.fold(0, (s, i) => s + i.cantidad);

  void clear() {
    _items.clear();
    _saveCart();
    notifyListeners();
  }

  // Construye DetalleVenta usando la info del carrito.
  // Necesitas pasar idVenta real cuando tengas la venta creada en el backend.
  List<Map<String, dynamic>> buildDetallesForVenta({required int idVenta}) {
    // devuelve una lista de jsons listos para enviar (o transformar a DetalleVenta)
    final List<Map<String, dynamic>> detalles = [];
    int nextIdDetalle =
        1; // placeholder; el servidor debería generar ids reales
    for (final it in _items) {
      final detalle = {
        'idDetalleVenta': nextIdDetalle++,
        'idVenta': idVenta,
        'idProducto': it.idProducto,
        'cantidad': it.cantidad,
        'precioUnitario': it.precioUnitario,
        'subtotal': it.subtotal,
      };
      detalles.add(detalle);
    }
    return detalles;
  }
}
