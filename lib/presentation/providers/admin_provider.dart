import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forra_store/data/services/admin_service.dart';
import 'package:forra_store/data/services/config_service.dart';

// ─── Modelos ─────────────────────────────────────────────────────────────────

class PresentacionAdmin {
  final int id;
  String unidad;    // "Kg", "Bulto", "Litro"…
  String cantidad;  // detalle opcional: "50 kg", "suelto", ""
  double precio;
  double? precioCosto; // precio de proveedor — usado en reportes para calcular ganancia
  int stock;
  int stockMinimo;

  PresentacionAdmin({
    required this.id,
    required this.unidad,
    this.cantidad = '',
    required this.precio,
    this.precioCosto,
    required this.stock,
    required this.stockMinimo,
  });

  String get descripcion {
    final c = cantidad.trim();
    return c.isEmpty ? unidad : '$unidad $c';
  }

  bool get enAlerta => stock <= stockMinimo;

  factory PresentacionAdmin.fromJson(Map<String, dynamic> j) => PresentacionAdmin(
    id: j['id'] as int,
    unidad: j['unidad'] as String,
    cantidad: j['cantidad'] as String? ?? '',
    precio: (j['precio'] as num).toDouble(),
    precioCosto: (j['precioCosto'] as num?)?.toDouble(),
    stock: j['stock'] as int,
    stockMinimo: j['stockMinimo'] as int,
  );

  Map<String, dynamic> toJson() => {
    'unidad': unidad,
    'cantidad': cantidad,
    'precio': precio,
    'precioCosto': precioCosto,
    'stock': stock,
    'stockMinimo': stockMinimo,
  };
}

class ProductoAdmin {
  final int id;
  String nombre;
  String descripcion;
  String categoria;
  String subcategoria;
  String uso;
  String imagenUrl;
  List<PresentacionAdmin> presentaciones;

  ProductoAdmin({
    required this.id,
    required this.nombre,
    this.descripcion = '',
    required this.categoria,
    this.subcategoria = '',
    this.uso = '',
    this.imagenUrl = '',
    required this.presentaciones,
  });

  int get stockTotal => presentaciones.fold(0, (s, p) => s + p.stock);
  bool get tieneAlerta => presentaciones.any((p) => p.enAlerta);
  String get stockStatus {
    if (presentaciones.isEmpty) return 'ok';
    if (presentaciones.every((p) => p.enAlerta)) return 'critico';
    if (tieneAlerta) return 'alerta';
    return 'ok';
  }

  factory ProductoAdmin.fromJson(Map<String, dynamic> j) => ProductoAdmin(
    id: j['id'] as int,
    nombre: j['nombre'] as String,
    descripcion: j['descripcion'] as String? ?? '',
    categoria: j['categoria'] as String? ?? '',
    subcategoria: j['subcategoria'] as String? ?? '',
    uso: j['uso'] as String? ?? '',
    imagenUrl: j['imagenUrl'] as String? ?? '',
    presentaciones: (j['presentaciones'] as List? ?? [])
        .map((p) => PresentacionAdmin.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

class PrecioEspecialAdmin {
  final int idProducto;
  final int idPresentacion;
  String productoNombre;
  String presentacionDesc;
  double precioLista;
  double precioEspecial;

  PrecioEspecialAdmin({
    required this.idProducto,
    required this.idPresentacion,
    required this.productoNombre,
    required this.presentacionDesc,
    required this.precioLista,
    required this.precioEspecial,
  });

  double get ahorro => precioLista - precioEspecial;

  factory PrecioEspecialAdmin.fromJson(Map<String, dynamic> j) => PrecioEspecialAdmin(
    idProducto: j['idProducto'] as int,
    idPresentacion: j['idPresentacion'] as int,
    productoNombre: j['productoNombre'] as String,
    presentacionDesc: j['presentacionDesc'] as String,
    precioLista: (j['precioLista'] as num).toDouble(),
    precioEspecial: (j['precioEspecial'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'idPresentacion': idPresentacion,
    'productoNombre': productoNombre,
    'presentacionDesc': presentacionDesc,
    'precioLista': precioLista,
    'precioEspecial': precioEspecial,
  };
}

class ClienteAdmin {
  final int id;
  String nombre;
  String telefono;
  List<PrecioEspecialAdmin> precios;

  ClienteAdmin({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.precios,
  });

  factory ClienteAdmin.fromJson(Map<String, dynamic> j) => ClienteAdmin(
    id: j['id'] as int,
    nombre: j['nombre'] as String,
    telefono: j['telefono'] as String? ?? '',
    precios: (j['precios'] as List? ?? [])
        .map((p) => PrecioEspecialAdmin.fromJson(p as Map<String, dynamic>))
        .toList(),
  );
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class AdminProvider extends ChangeNotifier {
  bool isLoading = false;
  String? error;

  // ── Listas de opciones (seeds + extras del usuario) ──────────────

  static const _seedCategorias = [
    'Alimento', 'Accesorios', 'Maquinaria', 'Semillas',
    'Veterinario', 'Agroquímicos', 'Granos',
  ];

  static const _seedSubcategorias = [
    'Bovino', 'Aves', 'Porcino', 'Equino', 'Ovino',
    'Canino', 'Felino', 'General', 'Insecticidas', 'Maíz', 'Pasto',
  ];

  static const _seedUnidades = [
    'Kg', 'Gramo', 'Tonelada',
    'Bulto', 'Bolsa', 'Paca', 'Caja',
    'Litro', 'Galón', 'Bidón', 'Frasco',
    'Pieza ch', 'Pieza med', 'Pieza gra', 'Pieza',
    'Dosis', 'Rollo', 'Par', 'Juego',
  ];

  final List<String> _categorias = [..._seedCategorias];
  final List<String> _subcategorias = [..._seedSubcategorias];
  final List<String> _unidades = [..._seedUnidades];

  List<String> get categorias => List.unmodifiable(_categorias);
  List<String> get subcategorias => List.unmodifiable(_subcategorias);
  List<String> get unidades => List.unmodifiable(_unidades);

  AdminProvider() {
    _loadListas();
    init();
  }

  Future<void> init() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final rawProductos = await AdminService.getProductos();
      final rawClientes  = await AdminService.getClientes();
      _productos
        ..clear()
        ..addAll(rawProductos.map(ProductoAdmin.fromJson));
      _clientes
        ..clear()
        ..addAll(rawClientes.map(ClienteAdmin.fromJson));
    } catch (e) {
      error = e.toString();
      debugPrint('AdminProvider.init error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Persistencia de listas ────────────────────────────────────────

  Future<void> _loadListas() async {
    final prefs = await SharedPreferences.getInstance();
    _merge(_categorias, prefs.getStringList('admin_categorias_v1'));
    _merge(_subcategorias, prefs.getStringList('admin_subcategorias_v1'));
    _merge(_unidades, prefs.getStringList('admin_unidades_v1'));
    notifyListeners();
  }

  void _merge(List<String> target, List<String>? saved) {
    if (saved == null) return;
    for (final s in saved) {
      if (!target.contains(s)) target.add(s);
    }
  }

  Future<void> _saveListas() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('admin_categorias_v1', _categorias);
    await prefs.setStringList('admin_subcategorias_v1', _subcategorias);
    await prefs.setStringList('admin_unidades_v1', _unidades);
  }

  void addCategoria(String c) {
    final t = c.trim();
    if (t.isEmpty || _categorias.contains(t)) return;
    _categorias.add(t);
    _saveListas();
    notifyListeners();
    ConfigService.addCategoria(t).catchError((_) {});
  }

  void addSubcategoria(String s) {
    final t = s.trim();
    if (t.isEmpty || _subcategorias.contains(t)) return;
    _subcategorias.add(t);
    _saveListas();
    notifyListeners();
    ConfigService.addSubcategoria(t).catchError((_) {});
  }

  void addUnidad(String u) {
    final t = u.trim();
    if (t.isEmpty || _unidades.contains(t)) return;
    _unidades.add(t);
    _saveListas();
    notifyListeners();
    ConfigService.addUnidad(t).catchError((_) {});
  }

  // ── Datos (cargados desde API) ─────────────────────────────────

  final List<ProductoAdmin> _productos = [];
  final List<ClienteAdmin> _clientes = [];

  List<ProductoAdmin> get productos => List.unmodifiable(_productos);
  List<ClienteAdmin> get clientes => List.unmodifiable(_clientes);

  // ── CRUD Productos ────────────────────────────────────────────────

  Future<int> addProducto(ProductoAdmin p) async {
    final id = await AdminService.createProducto({
      'nombre': p.nombre,
      'descripcion': p.descripcion,
      'categoria': p.categoria,
      'subcategoria': p.subcategoria,
      'uso': p.uso,
      'imagenUrl': p.imagenUrl,
      'presentaciones': p.presentaciones.map((pr) => pr.toJson()).toList(),
    });
    await init();
    return id;
  }

  Future<void> subirImagenProducto(int idProducto, File imagen) async {
    final imagenUrl = await AdminService.subirImagenProducto(idProducto, imagen);
    final idx = _productos.indexWhere((p) => p.id == idProducto);
    if (idx >= 0) {
      _productos[idx].imagenUrl = imagenUrl;
      notifyListeners();
    }
  }

  Future<void> updateProducto(int id, {
    required String nombre,
    required String descripcion,
    required String categoria,
    required String subcategoria,
    required String uso,
    required String imagenUrl,
  }) async {
    // Actualización optimista
    final idx = _productos.indexWhere((p) => p.id == id);
    if (idx >= 0) {
      _productos[idx]
        ..nombre = nombre
        ..descripcion = descripcion
        ..categoria = categoria
        ..subcategoria = subcategoria
        ..uso = uso
        ..imagenUrl = imagenUrl;
      notifyListeners();
    }
    await AdminService.updateProducto(id, {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'subcategoria': subcategoria,
      'uso': uso,
      'imagenUrl': imagenUrl,
    });
  }

  Future<void> deleteProducto(int id) async {
    _productos.removeWhere((p) => p.id == id);
    for (final c in _clientes) {
      c.precios.removeWhere((pr) => pr.idProducto == id);
    }
    notifyListeners();
    await AdminService.deleteProducto(id);
  }

  Future<void> addStock(int idProducto, int idPresentacion, int cantidad) async {
    final p = _findProducto(idProducto);
    if (p == null) return;
    final idx = p.presentaciones.indexWhere((pr) => pr.id == idPresentacion);
    if (idx >= 0) {
      p.presentaciones[idx].stock += cantidad;
      notifyListeners();
    }
    await AdminService.addStock(idPresentacion, cantidad);
  }

  Future<void> addPresentacion(int idProducto, PresentacionAdmin pr) async {
    await AdminService.addPresentacion(idProducto, pr.toJson());
    await init();
  }

  Future<void> updatePresentacion(int idProducto, int idPresentacion, PresentacionAdmin data) async {
    final p = _findProducto(idProducto);
    if (p == null) return;
    final idx = p.presentaciones.indexWhere((pr) => pr.id == idPresentacion);
    if (idx >= 0) {
      p.presentaciones[idx] = PresentacionAdmin(
        id: idPresentacion,
        unidad: data.unidad,
        cantidad: data.cantidad,
        precio: data.precio,
        precioCosto: data.precioCosto,
        stock: data.stock,
        stockMinimo: data.stockMinimo,
      );
      notifyListeners();
    }
    await AdminService.updatePresentacion(idPresentacion, data.toJson());
  }

  Future<void> deletePresentacion(int idProducto, int idPresentacion) async {
    final p = _findProducto(idProducto);
    if (p == null) return;
    p.presentaciones.removeWhere((pr) => pr.id == idPresentacion);
    for (final c in _clientes) {
      c.precios.removeWhere((pr) => pr.idPresentacion == idPresentacion);
    }
    notifyListeners();
    await AdminService.deletePresentacion(idPresentacion);
  }

  // ── CRUD Clientes ─────────────────────────────────────────────────

  Future<void> addCliente(ClienteAdmin c) async {
    await AdminService.createCliente({'nombre': c.nombre, 'telefono': c.telefono});
    await init();
  }

  Future<void> updateCliente(int id, String nombre, String telefono) async {
    final idx = _clientes.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      _clientes[idx].nombre = nombre;
      _clientes[idx].telefono = telefono;
      notifyListeners();
    }
    await AdminService.updateCliente(id, {'nombre': nombre, 'telefono': telefono});
  }

  Future<void> deleteCliente(int id) async {
    _clientes.removeWhere((c) => c.id == id);
    notifyListeners();
    await AdminService.deleteCliente(id);
  }

  void setPrecioEspecial(int idCliente, PrecioEspecialAdmin precio) {
    final c = _findCliente(idCliente);
    if (c == null) return;
    final idx = c.precios.indexWhere(
      (p) => p.idProducto == precio.idProducto && p.idPresentacion == precio.idPresentacion,
    );
    if (idx >= 0) {
      c.precios[idx] = precio;
    } else {
      c.precios.add(precio);
    }
    notifyListeners();
  }

  void removePrecioEspecial(int idCliente, int idProducto, int idPresentacion) {
    final c = _findCliente(idCliente);
    if (c == null) return;
    c.precios.removeWhere(
      (p) => p.idProducto == idProducto && p.idPresentacion == idPresentacion,
    );
    notifyListeners();
  }

  Future<void> saveDescuentosCliente(int idCliente, List<PrecioEspecialAdmin> nuevosPrecios) async {
    final c = _findCliente(idCliente);
    if (c == null) return;
    c.precios
      ..clear()
      ..addAll(nuevosPrecios);
    notifyListeners();
    await AdminService.savePrecios(
      idCliente,
      nuevosPrecios.map((p) => p.toJson()).toList(),
    );
  }

  ProductoAdmin? _findProducto(int id) {
    try { return _productos.firstWhere((p) => p.id == id); } catch (_) { return null; }
  }

  ClienteAdmin? _findCliente(int id) {
    try { return _clientes.firstWhere((c) => c.id == id); } catch (_) { return null; }
  }
}
