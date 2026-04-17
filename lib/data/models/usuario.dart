class Usuario {
  final int? idUsuario;
  final String strUsuario;
  final String strContrasena;
  final int idRol;
  final int? idSucursal;

  Usuario({
    this.idUsuario,
    required this.strUsuario,
    required this.strContrasena,
    required this.idRol,
    this.idSucursal,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    idUsuario: json['idUsuario'],
    strUsuario: json['strUsuario'],
    strContrasena: json['strContrasena'],
    idRol: json['idRol'],
    idSucursal: json['idSucursal'],
  );

  Map<String, dynamic> toJson() => {
    'idUsuario': idUsuario,
    'strUsuario': strUsuario,
    'strContrasena': strContrasena,
    'idRol': idRol,
    'idSucursal': idSucursal,
  };
}
