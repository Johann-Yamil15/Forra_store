class Subcategoria {
  final int idSubcategoria;
  final String nombre;
  final String? descripcion;
  final int idCategoria;
  final bool activo;

  Subcategoria({
    required this.idSubcategoria,
    required this.nombre,
    this.descripcion,
    required this.idCategoria,
    this.activo = true,
  });

  factory Subcategoria.fromJson(Map<String, dynamic> json) {
    return Subcategoria(
      idSubcategoria: json['idSubcategoria'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      idCategoria: json['idCategoria'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSubcategoria': idSubcategoria,
      'nombre': nombre,
      'descripcion': descripcion,
      'idCategoria': idCategoria,
      'activo': activo,
    };
  }
}
