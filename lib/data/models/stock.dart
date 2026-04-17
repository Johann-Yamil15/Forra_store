class Stock {
  final int idStock;
  final int idProducto;
  final int cantidad;
  final int idSucursal;
  final bool activo;

  Stock({
    required this.idStock,
    required this.idProducto,
    required this.cantidad,
    required this.idSucursal,
    this.activo = true,
  });

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      idStock: json['idStock'],
      idProducto: json['idProducto'],
      cantidad: json['cantidad'],
      idSucursal: json['idSucursal'],
      activo: json['activo'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idStock': idStock,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'idSucursal': idSucursal,
      'activo': activo,
    };
  }
}
