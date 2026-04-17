class Producto {
  final int? idProducto;
  final int idSubcategoria;
  final String strNombre;
  final String? strDescripcion;
  final int? idUsoProducto;

  Producto({
    this.idProducto,
    required this.idSubcategoria,
    required this.strNombre,
    this.strDescripcion,
    this.idUsoProducto,
  });

  factory Producto.fromJson(Map<String, dynamic> json) => Producto(
    idProducto: json['idProducto'],
    idSubcategoria: json['idSubcategoria'],
    strNombre: json['strNombre'],
    strDescripcion: json['strDescripcion'],
    idUsoProducto: json['idUsoProducto'],
  );

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'idSubcategoria': idSubcategoria,
    'strNombre': strNombre,
    'strDescripcion': strDescripcion,
    'idUsoProducto': idUsoProducto,
  };
}
