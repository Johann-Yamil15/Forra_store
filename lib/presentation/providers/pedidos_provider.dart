import 'package:flutter/material.dart';
import 'package:forra_store/data/models/pedido.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedidosProvider extends ChangeNotifier {
  static const _storageKey = 'pedidos_history_v1';
  final List<Pedido> _pedidos = [];

  List<Pedido> get pedidos => List.unmodifiable(_pedidos);

  PedidosProvider() {
    _loadPedidos();
  }

  Future<void> _loadPedidos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = Pedido.decodeList(raw);
        _pedidos.clear();
        _pedidos.addAll(decoded);
        // Ordenar por fecha descendente (más recientes primero)
        _pedidos.sort((a, b) => b.fecha.compareTo(a.fecha));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading pedidos: $e');
    }
  }

  Future<void> _savePedidos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, Pedido.encodeList(_pedidos));
  }

  void agregarPedido(Pedido pedido) {
    _pedidos.insert(0, pedido); // Insertar al inicio
    _savePedidos();
    notifyListeners();
  }

  void eliminarPedido(String id) {
    _pedidos.removeWhere((p) => p.id == id);
    _savePedidos();
    notifyListeners();
  }

  Pedido? getPedidoById(String id) {
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
