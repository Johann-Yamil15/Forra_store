class Venta {
  final int idVenta;
  final int idSucursal;
  final DateTime fecha;
  final double total;

  Venta({
    required this.idVenta,
    required this.idSucursal,
    required this.fecha,
    required this.total,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      idVenta: json['idVenta'],
      idSucursal: json['idSucursal'],
      fecha: DateTime.parse(json['fecha']),
      total: (json['total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idVenta': idVenta,
      'idSucursal': idSucursal,
      'fecha': fecha.toIso8601String(),
      'total': total,
    };
  }
}
