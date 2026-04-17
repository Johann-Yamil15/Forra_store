class Categoria {
  final int idCategoria;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Categoria({
    required this.idCategoria,
    required this.nombre,
    this.descripcion,
    this.activo = true,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: json['idCategoria'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCategoria': idCategoria,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
