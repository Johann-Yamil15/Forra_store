class Movimiento {
  final int idMovimiento;
  final int idProducto;
  final int cantidad;
  final String tipo; // Entrada, Salida
  final DateTime fecha;
  final int idSucursal;

  Movimiento({
    required this.idMovimiento,
    required this.idProducto,
    required this.cantidad,
    required this.tipo,
    required this.fecha,
    required this.idSucursal,
  });

  factory Movimiento.fromJson(Map<String, dynamic> json) {
    return Movimiento(
      idMovimiento: json['idMovimiento'],
      idProducto: json['idProducto'],
      cantidad: json['cantidad'],
      tipo: json['tipo'],
      fecha: DateTime.parse(json['fecha']),
      idSucursal: json['idSucursal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idMovimiento': idMovimiento,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'idSucursal': idSucursal,
    };
  }
}
