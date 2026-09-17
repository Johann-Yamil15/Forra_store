/// Snapshot de una venta ya registrada, con los datos necesarios para
/// imprimir su ticket. Se arma en el momento del checkout (antes de limpiar
/// el carrito) porque la API de creación solo devuelve el id de la venta.
class VentaTicketItem {
  final String nombreProducto;
  final String unidad;
  final String tamano;
  final int cantidad;
  final double precioUnitario;
  final double precioEfectivo;

  VentaTicketItem({
    required this.nombreProducto,
    required this.unidad,
    required this.tamano,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioEfectivo,
  });

  double get subtotal => precioEfectivo * cantidad;
}

class VentaTicket {
  final int idVenta;
  final DateTime fecha;
  // Null cuando se reimprime desde el historial: varios trabajadores
  // comparten un solo punto de venta, así que no hay un vendedor específico
  // que registrar ahí (sí se conoce en el momento del checkout).
  final String? vendedor;
  final String? cliente;
  final List<VentaTicketItem> items;
  final double totalOriginal;
  final double descuento;
  final double totalFinal;

  VentaTicket({
    required this.idVenta,
    required this.fecha,
    this.vendedor,
    this.cliente,
    required this.items,
    required this.totalOriginal,
    required this.descuento,
    required this.totalFinal,
  });
}
