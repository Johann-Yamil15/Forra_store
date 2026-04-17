class Presentacion {
  final int idPresentacion;
  final String nombre;
  final String? descripcion;
  final bool activo;

  Presentacion({
    required this.idPresentacion,
    required this.nombre,
    this.descripcion,
    this.activo = true,
  });

  factory Presentacion.fromJson(Map<String, dynamic> json) {
    return Presentacion(
      idPresentacion: json['idPresentacion'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idPresentacion': idPresentacion,
      'nombre': nombre,
      'descripcion': descripcion,
      'activo': activo,
    };
  }
}
