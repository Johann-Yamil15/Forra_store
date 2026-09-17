import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:forra_store/core/constants/store_info.dart';
import 'package:forra_store/data/models/venta_ticket.dart';

enum TicketAlign { left, center }

/// Una línea del ticket, independiente de si termina como bytes ESC/POS o
/// como texto en pantalla — así la vista previa (sin impresora) y la
/// impresión real nunca pueden desincronizarse: ambas recorren [_lineas].
class TicketLinea {
  final String texto;
  final TicketAlign align;
  final bool bold;
  const TicketLinea(this.texto, {this.align = TicketAlign.left, this.bold = false});
}

/// Arma un ticket de venta para una impresora térmica de 58 mm (32
/// caracteres por línea con la fuente A, que es lo que usa PaperSize.mm58
/// en esc_pos_utils_plus).
class TicketFormatter {
  static const width = 32;

  static Future<List<int>> build(VentaTicket venta) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    var bytes = <int>[];

    for (final l in _lineas(venta)) {
      bytes += generator.text(
        l.texto,
        styles: PosStyles(
          align: l.align == TicketAlign.center ? PosAlign.center : PosAlign.left,
          bold: l.bold,
        ),
      );
    }
    bytes += generator.feed(3);
    bytes += generator.cut();

    return bytes;
  }

  /// Mismo contenido que [build], como texto plano — para mostrar una
  /// vista previa en pantalla sin necesitar la impresora conectada.
  static List<TicketLinea> previewLines(VentaTicket venta) => _lineas(venta);

  static List<TicketLinea> _lineas(VentaTicket venta) {
    final lineas = <TicketLinea>[];
    void add(String texto, {TicketAlign align = TicketAlign.left, bool bold = false}) =>
        lineas.add(TicketLinea(_clean(texto), align: align, bold: bold));
    void hr() => add('-' * width);

    // ── Encabezado ──────────────────────────────────────────────────────
    add(StoreInfo.nombre, align: TicketAlign.center, bold: true);
    add(StoreInfo.direccion, align: TicketAlign.center);
    add(StoreInfo.telefono, align: TicketAlign.center);
    hr();

    add('Folio: ${venta.idVenta.toString().padLeft(6, '0')}');
    add('Fecha: ${_fmtFecha(venta.fecha)}  ${_fmtHora(venta.fecha)}');
    if (venta.vendedor != null) {
      add('Atendio: ${venta.vendedor}');
    }
    add('Cliente: ${venta.cliente ?? 'Publico en general'}');
    hr();

    // ── Detalle de venta ────────────────────────────────────────────────
    for (final item in venta.items) {
      final presentacion = item.tamano.trim().isEmpty ? item.unidad : '${item.unidad} ${item.tamano}';
      final descripcion = '${item.nombreProducto} ($presentacion)';
      for (final linea in _wrap('${item.cantidad}x $descripcion', width)) {
        add(linea);
      }
      final tieneDescuento = item.precioEfectivo < item.precioUnitario;
      add(_twoCols('  ${_money(item.precioEfectivo)} c/u', _money(item.subtotal)));
      if (tieneDescuento) {
        add(_twoCols('  Precio lista:', _money(item.precioUnitario)));
      }
    }
    hr();

    // ── Totales ─────────────────────────────────────────────────────────
    add(_twoCols('Subtotal:', _money(venta.totalOriginal)));
    if (venta.descuento > 0) {
      add(_twoCols('Descuento:', '-${_money(venta.descuento)}'));
    }
    hr();
    add(_twoCols('TOTAL:', _money(venta.totalFinal)), bold: true);

    // ── Pie de página ───────────────────────────────────────────────────
    add('');
    add('Gracias por su compra!', align: TicketAlign.center, bold: true);
    add('Vuelva pronto', align: TicketAlign.center);

    return lineas;
  }

  static String _money(double v) => '\$${v.toStringAsFixed(2)}';

  /// Reparte [left] y [right] en una línea de [width] caracteres. Si no
  /// caben ambos, recorta [left] — nunca corta el importe de la derecha.
  static String _twoCols(String left, String right) {
    final espacio = width - left.length - right.length;
    if (espacio < 1) {
      final maxLeft = (width - right.length - 1).clamp(0, left.length);
      return '${left.substring(0, maxLeft)} $right';
    }
    return left + ' ' * espacio + right;
  }

  /// Corta [text] en líneas de máximo [ancho] caracteres, respetando
  /// palabras completas cuando es posible.
  static List<String> _wrap(String text, int ancho) {
    final palabras = text.split(' ');
    final lineas = <String>[];
    var actual = '';
    for (final palabra in palabras) {
      final candidata = actual.isEmpty ? palabra : '$actual $palabra';
      if (candidata.length > ancho) {
        if (actual.isNotEmpty) lineas.add(actual);
        actual = palabra.length > ancho ? palabra.substring(0, ancho) : palabra;
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
