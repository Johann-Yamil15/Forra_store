class PresentacionProducto {
  final int idPresentacion;
  final String unidad;
  final String tamano;   // descripción del tamaño: "50 kg", "suelto", ""
  final double precio;
  final int stock;

  PresentacionProducto({
    required this.idPresentacion,
    required this.unidad,
    required this.tamano,
    required this.precio,
    required this.stock,
  });

  factory PresentacionProducto.fromJson(Map<String, dynamic> json) {
    // La API puede devolver 'cantidad' (string) o 'tamano' (num o string)
    final rawTamano = json['cantidad'] ?? json['tamano'];
    final tamano = rawTamano is num ? rawTamano.toString() : (rawTamano as String? ?? '');
    return PresentacionProducto(
      idPresentacion: json['idPresentacion'] as int,
      unidad: json['unidad'] as String,
      tamano: tamano,
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'idPresentacion': idPresentacion,
    'unidad': unidad,
    'tamano': tamano,
    'precio': precio,
    'stock': stock,
  };
}

class ProductoPreview {
  final int idProducto;
  final String nombreProducto;
  final String descripcionProducto;
  final String categoria;
  final String subcategoria;
  final String uso;
  final String imagenUrl;
  final List<PresentacionProducto> presentaciones;

  ProductoPreview({
    required this.idProducto,
    required this.nombreProducto,
    required this.descripcionProducto,
    required this.categoria,
    required this.subcategoria,
    required this.uso,
    required this.imagenUrl,
    required this.presentaciones,
  });

  factory ProductoPreview.fromJson(Map<String, dynamic> json) {
    return ProductoPreview(
      idProducto: json['idProducto'] as int,
      nombreProducto: json['nombreProducto'] as String,
      descripcionProducto: json['descripcionProducto'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      subcategoria: json['subcategoria'] as String? ?? '',
      uso: json['uso'] as String? ?? '',
      imagenUrl: json['imagenUrl'] as String? ?? '',
      presentaciones: (json['presentaciones'] as List)
          .map((p) => PresentacionProducto.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'nombreProducto': nombreProducto,
    'descripcionProducto': descripcionProducto,
    'categoria': categoria,
    'subcategoria': subcategoria,
    'uso': uso,
    'imagenUrl': imagenUrl,
    'presentaciones': presentaciones.map((p) => p.toJson()).toList(),
  };
}
