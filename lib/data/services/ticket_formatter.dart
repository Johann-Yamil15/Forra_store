import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:forra_store/core/constants/store_info.dart';
import 'package:forra_store/data/models/venta_ticket.dart';

/// Arma los bytes ESC/POS de un ticket de venta para una impresora térmica
/// de 58 mm (32 caracteres por línea con la fuente A, que es lo que usa
/// PaperSize.mm58 en esc_pos_utils_plus).
class TicketFormatter {
  static const _width = 32;

  static Future<List<int>> build(VentaTicket venta) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    var bytes = <int>[];

    // ── Encabezado ──────────────────────────────────────────────────────
    bytes += generator.text(
      StoreInfo.nombre,
      styles: const PosStyles(align: PosAlign.center, bold: true),
    );
    bytes += generator.text(_clean(StoreInfo.direccion), styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text(_clean(StoreInfo.telefono), styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr();

    bytes += generator.text(_clean('Folio: ${venta.idVenta.toString().padLeft(6, '0')}'));
    bytes += generator.text(_clean('Fecha: ${_fmtFecha(venta.fecha)}  ${_fmtHora(venta.fecha)}'));
    if (venta.vendedor != null) {
      bytes += generator.text(_clean('Atendio: ${venta.vendedor}'));
    }
    bytes += generator.text(_clean('Cliente: ${venta.cliente ?? 'Publico en general'}'));
    bytes += generator.hr();

    // ── Detalle de venta ────────────────────────────────────────────────
    for (final item in venta.items) {
      final presentacion = item.tamano.trim().isEmpty ? item.unidad : '${item.unidad} ${item.tamano}';
      final descripcion = _clean('${item.nombreProducto} ($presentacion)');
      for (final linea in _wrap('${item.cantidad}x $descripcion', _width)) {
        bytes += generator.text(linea);
      }
      final tieneDescuento = item.precioEfectivo < item.precioUnitario;
      bytes += generator.text(_twoCols(
        '  ${_money(item.precioEfectivo)} c/u',
        _money(item.subtotal),
      ));
      if (tieneDescuento) {
        bytes += generator.text(_twoCols('  Precio lista:', _money(item.precioUnitario)));
      }
    }
    bytes += generator.hr();

    // ── Totales ─────────────────────────────────────────────────────────
    bytes += generator.text(_twoCols('Subtotal:', _money(venta.totalOriginal)));
    if (venta.descuento > 0) {
      bytes += generator.text(_twoCols('Descuento:', '-${_money(venta.descuento)}'));
    }
    bytes += generator.hr();
    bytes += generator.text(
      _twoCols('TOTAL:', _money(venta.totalFinal)),
      styles: const PosStyles(bold: true),
    );

    // ── Pie de página ───────────────────────────────────────────────────
    bytes += generator.feed(1);
    bytes += generator.text('Gracias por su compra!', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Vuelva pronto', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  static String _money(double v) => '\$${v.toStringAsFixed(2)}';

  /// Reparte [left] y [right] en una línea de [_width] caracteres. Si no
  /// caben ambos, recorta [left] — nunca corta el importe de la derecha.
  static String _twoCols(String left, String right) {
    final espacio = _width - left.length - right.length;
    if (espacio < 1) {
      final maxLeft = (_width - right.length - 1).clamp(0, left.length);
      return '${left.substring(0, maxLeft)} $right';
    }
    return left + ' ' * espacio + right;
  }

  /// Corta [text] en líneas de máximo [width] caracteres, respetando
  /// palabras completas cuando es posible.
  static List<String> _wrap(String text, int width) {
    final palabras = text.split(' ');
    final lineas = <String>[];
    var actual = '';
    for (final palabra in palabras) {
      final candidata = actual.isEmpty ? palabra : '$actual $palabra';
      if (candidata.length > width) {
        if (actual.isNotEmpty) lineas.add(actual);
        actual = palabra.length > width ? palabra.substring(0, width) : palabra;
      } else {
        actual = candidata;
      }
    }
    if (actual.isNotEmpty) lineas.add(actual);
    return lineas;
  }

  static String _fmtFecha(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  static String _fmtHora(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  // La mayoría de las impresoras térmicas genéricas (como la MP210) traen
  // por defecto una tabla de códigos (CP437) que no coincide con los acentos
  // en Latin-1/UTF-8 — imprimirlos tal cual sale texto ilegible. Se
  // reemplazan por su equivalente sin acento para garantizar que el ticket
  // se vea limpio en cualquier impresora, sin depender de su code page.
  static const _acentos = {
    'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
    'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
    'ñ': 'n', 'Ñ': 'N', 'ü': 'u', 'Ü': 'U',
    '¡': '', '¿': '',
  };

  static String _clean(String text) {
    var out = text;
    _acentos.forEach((k, v) => out = out.replaceAll(k, v));
    return out;
  }
}
