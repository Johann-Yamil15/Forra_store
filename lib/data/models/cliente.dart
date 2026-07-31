class Cliente {
  final int id;
  final String nombre;
  final String telefono;
  // idPresentacion → precioEspecial
  final Map<int, double> descuentos;

  Cliente({
    required this.id,
    required this.nombre,
    this.telefono = '',
    required this.descuentos,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final map = <int, double>{};
    final lista = json['descuentos'] as List? ?? [];
    for (final d in lista) {
      map[d['idPresentacion'] as int] = (d['precioEspecial'] as num).toDouble();
    }
    return Cliente(
      id: json['idCliente'] as int,
      nombre: json['nombre'] as String,
      telefono: json['telefono'] as String? ?? '',
      descuentos: map,
    );
  }
}
