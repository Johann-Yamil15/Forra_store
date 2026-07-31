import 'package:flutter/material.dart';
import 'package:forra_store/data/models/cart_item.dart';
import 'package:forra_store/data/models/cliente.dart';
import 'package:forra_store/data/services/cliente_service.dart';
import 'package:forra_store/data/services/venta_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  static const _storageKey = 'cart_items_v1';

  final List<CartItem> _items = [];
  Cliente? _selectedCliente;

  List<Cliente> clientes = [];
  bool clientesCargando = false;
  bool isCheckingOut = false;

  List<CartItem> get items => List.unmodifiable(_items);
  Cliente? get selectedCliente => _selectedCliente;

  CartProvider() {
    _loadCart();
    loadClientes();
  }

  // ── Clientes desde API ────────────────────────────────────────────────────

  Future<void> loadClientes() async {
    clientesCargando = true;
    notifyListeners();
    try {
      clientes = await ClienteService.getClientes();
    } catch (e) {
      debugPrint('Error cargando clientes: $e');
    }
    clientesCargando = false;
    notifyListeners();
  }

  // ── Carrito local ─────────────────────────────────────────────────────────

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        _items
          ..clear()
          ..addAll(CartItem.decodeList(raw));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, CartItem.encodeList(_items));
  }

  void addItem(CartItem item) {
    final index = _items.indexWhere(
      (i) => i.idPresentacion == item.idPresentacion,
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
      (i) => i.idPresentacion == item.idPresentacion,
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
    _items.removeWhere((i) => i.idPresentacion == item.idPresentacion);
    _saveCart();
    notifyListeners();
  }

  void selectCliente(Cliente? cliente) {
    _selectedCliente = cliente;
    notifyListeners();
  }

  double getItemPrice(CartItem item) {
    if (_selectedCliente != null) {
      final especial = _selectedCliente!.descuentos[item.idPresentacion];
      if (especial != null) return especial;
    }
    return item.precioUnitario;
  }

  double get totalOriginal =>
      _items.fold(0.0, (s, i) => s + i.precioUnitario * i.cantidad);

  double get totalFinal =>
      _items.fold(0.0, (s, i) => s + getItemPrice(i) * i.cantidad);

  double get totalDescuento => totalOriginal - totalFinal;

  double get total => totalFinal;

  int get totalItems => _items.fold(0, (s, i) => s + i.cantidad);

  void clear() {
    _items.clear();
    _selectedCliente = null;
    _saveCart();
    notifyListeners();
  }

  // ── Checkout → API ────────────────────────────────────────────────────────

  /// Registra la venta en el servidor. Devuelve el idVenta asignado.
  /// Lanza excepción si falla. No limpia el carrito (hazlo tú tras el éxito).
  Future<int> checkout({required int idUsuario}) async {
    isCheckingOut = true;
    notifyListeners();
    try {
      final itemsConPrecio = _items.map((item) {
        final efectivo = getItemPrice(item);
        if (efectivo == item.precioUnitario) return item;
        return CartItem(
          idProducto: item.idProducto,
          idPresentacion: item.idPresentacion,
          nombreProducto: item.nombreProducto,
          imagenUrl: item.imagenUrl,
          unidad: item.unidad,
          tamano: item.tamano,
          precioUnitario: item.precioUnitario,
          precioEfectivo: efectivo,
          cantidad: item.cantidad,
        );
      }).toList();

      return await VentaService.crearVenta(
        idUsuario: idUsuario,
        idCliente: _selectedCliente?.id,
        totalOriginal: totalOriginal,
        descuento: totalDescuento,
        totalFinal: totalFinal,
        items: itemsConPrecio,
      );
    } finally {
      isCheckingOut = false;
      notifyListeners();
    }
  }
}
