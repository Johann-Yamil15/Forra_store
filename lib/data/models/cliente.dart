class Cliente {
  final int id;
  final String nombre;
  final Map<int, Map<String, double>> descuentos; // idProducto -> {unidad: precioEspecial}

  Cliente({
    required this.id,
    required this.nombre,
    required this.descuentos,
  });
}
