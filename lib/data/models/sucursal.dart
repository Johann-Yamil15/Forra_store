class Sucursal {
  final int idSucursal;
  final String nombre;
  final String direccion;
  final bool activo;

  Sucursal({
    required this.idSucursal,
    required this.nombre,
    required this.direccion,
    this.activo = true,
  });

  factory Sucursal.fromJson(Map<String, dynamic> json) {
    return Sucursal(
      idSucursal: json['idSucursal'],
      nombre: json['nombre'],
      direccion: json['direccion'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSucursal': idSucursal,
      'nombre': nombre,
      'direccion': direccion,
      'activo': activo,
    };
  }
}
