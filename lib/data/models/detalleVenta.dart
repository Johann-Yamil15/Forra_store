class DetalleVenta {
  final int idDetalleVenta;
  final int idVenta;
  final int idProducto;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVenta({
    required this.idDetalleVenta,
    required this.idVenta,
    required this.idProducto,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idDetalleVenta: json['idDetalleVenta'],
      idVenta: json['idVenta'],
      idProducto: json['idProducto'],
      cantidad: json['cantidad'],
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idDetalleVenta': idDetalleVenta,
      'idVenta': idVenta,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'precioUnitario': precioUnitario,
      'subtotal': subtotal,
    };
  }
}
