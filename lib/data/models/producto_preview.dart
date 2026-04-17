class PresentacionProducto {
  final String unidad;
  final int tamano;
  final double precio;
  final int stock;

  PresentacionProducto({
    required this.unidad,
    required this.tamano,
    required this.precio,
    required this.stock,
  });

  factory PresentacionProducto.fromJson(Map<String, dynamic> json) {
    return PresentacionProducto(
      unidad: json['unidad'],
      tamano: json['tamano'],
      precio: (json['precio'] as num).toDouble(),
      stock: json['stock'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "unidad": unidad,
      "tamano": tamano,
      "precio": precio,
      "stock": stock,
    };
  }
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
      idProducto: json['idProducto'],
      nombreProducto: json['nombreProducto'],
      descripcionProducto: json['descripcionProducto'],
      categoria: json['categoria'],
      subcategoria: json['subcategoria'],
      uso: json['uso'],
      imagenUrl: json['imagenUrl'],
      presentaciones:
          (json['presentaciones'] as List)
              .map((p) => PresentacionProducto.fromJson(p))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "idProducto": idProducto,
      "nombreProducto": nombreProducto,
      "descripcionProducto": descripcionProducto,
      "categoria": categoria,
      "subcategoria": subcategoria,
      "uso": uso,
      "imagenUrl": imagenUrl,
      "presentaciones": presentaciones.map((p) => p.toJson()).toList(),
    };
  }
}
