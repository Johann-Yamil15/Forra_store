class Rol {
  final int idRol;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Rol({
    required this.idRol,
    required this.nombre,
    this.descripcion,
    this.activo = true,
  });

  factory Rol.fromJson(Map<String, dynamic> json) {
    return Rol(
      idRol: json['idRol'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idRol': idRol,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
