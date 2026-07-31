import 'package:flutter/material.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

// ════════════════════════════════════════════════════════════════
//  FORMULARIO AGREGAR / EDITAR CLIENTE
// ════════════════════════════════════════════════════════════════

class ClienteFormScreen extends StatefulWidget {
  final ClienteAdmin? cliente;
  const ClienteFormScreen({super.key, this.cliente});

  bool get isEditing => cliente != null;

  @override
  State<ClienteFormScreen> createState() => _ClienteFormScreenState();
}

class _ClienteFormScreenState extends State<ClienteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _telefonoCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.cliente?.nombre ?? '');
    _telefonoCtrl = TextEditingController(text: widget.cliente?.telefono ?? '');
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<AdminProvider>();

    if (!widget.isEditing) {
      provider.addCliente(ClienteAdmin(
        id: 0,
        nombre: _nombreCtrl.text.trim(),
        telefono: _telefonoCtrl.text.trim(),
        precios: [],
      ));
    } else {
      provider.updateCliente(
        widget.cliente!.id,
        _nombreCtrl.text.trim(),
        _telefonoCtrl.text.trim(),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Editar Cliente' : 'Nuevo Cliente',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text(
              'GUARDAR',
              style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Avatar visual
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.primary.withValues(alpha: 0.3), width: 2),
                ),
                child: Icon(Icons.person, size: 40, color: colors.primary),
              ),
            ),
            const SizedBox(height: 32),

            _label('Nombre del cliente', colors),
            const SizedBox(height: 8),
            _field(
              controller: _nombreCtrl,
              hint: 'Ej. Juan García — Rancho El Nogal',
              icon: Icons.person_outline,
              colors: colors,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 20),

            _label('Teléfono', colors),
            const SizedBox(height: 8),
            _field(
              controller: _telefonoCtrl,
              hint: 'Ej. 867-100-0001',
              icon: Icons.phone_outlined,
              colors: colors,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 40),

            GestureDetector(
              onTap: _save,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  widget.isEditing ? 'Actualizar cliente' : 'Crear cliente',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            if (widget.isEditing) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _confirmDelete(context, colors),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.secondary.withValues(alpha: 0.3)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Eliminar cliente',
                    style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _label(String text, NeumorphicColors colors) => Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.5), letterSpacing: 0.5),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required NeumorphicColors colors,
    IconData? icon,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) {
    return Container(
      decoration: NeumorphicStyle.inset(colors, radius: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboard,
        style: TextStyle(color: colors.text, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.3)),
          icon: icon != null ? Icon(icon, color: colors.primary, size: 20) : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, NeumorphicColors colors) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('¿Eliminar cliente?', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
        content: Text(
          'Se eliminarán también todos sus precios especiales. Esta acción no se puede deshacer.',
          style: TextStyle(color: colors.text.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancelar', style: TextStyle(color: colors.text))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Eliminar', style: TextStyle(color: colors.secondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AdminProvider>().deleteCliente(widget.cliente!.id);
      Navigator.pop(context);
    }
  }
}

// ════════════════════════════════════════════════════════════════
//  PANTALLA DE PRECIOS ESPECIALES POR CLIENTE
// ════════════════════════════════════════════════════════════════

class ClienteDescuentosScreen extends StatefulWidget {
  final ClienteAdmin cliente;
  const ClienteDescuentosScreen({super.key, required this.cliente});

  @override
  State<ClienteDescuentosScreen> createState() => _ClienteDescuentosScreenState();
}

class _ClienteDescuentosScreenState extends State<ClienteDescuentosScreen> {
  // idPresentacion → TextEditingController con precio especial (vacío = sin descuento)
  final Map<int, TextEditingController> _ctrlMap = {};

  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<AdminProvider>();
    for (final producto in provider.productos) {
      for (final pr in producto.presentaciones) {
        final existing = widget.cliente.precios.where(
          (p) => p.idProducto == producto.id && p.idPresentacion == pr.id,
        );
        final texto = existing.isNotEmpty ? existing.first.precioEspecial.toStringAsFixed(2) : '';
        _ctrlMap[pr.id] = TextEditingController(text: texto);
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    for (final c in _ctrlMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _normalize(String s) => s
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll('ñ', 'n')
      .replaceAll(',', '')
      .replaceAll('.', '');

  List<ProductoAdmin> _filtered(List<ProductoAdmin> productos) {
    if (_query.isEmpty) return productos;
    final q = _normalize(_query);
    return productos.where((p) {
      if (_normalize(p.nombre).contains(q)) return true;
      if (_normalize(p.categoria).contains(q)) return true;
      if (_normalize(p.subcategoria).contains(q)) return true;
      return p.presentaciones.any((pr) => _normalize(pr.descripcion).contains(q));
    }).toList();
  }

  void _save() {
    final provider = context.read<AdminProvider>();
    final productos = provider.productos;
    final nuevosPrecios = <PrecioEspecialAdmin>[];

    for (final producto in productos) {
      for (final pr in producto.presentaciones) {
        final ctrl = _ctrlMap[pr.id];
        if (ctrl == null) continue;
        final val = double.tryParse(ctrl.text.trim());
        if (val != null && val > 0 && val < pr.precio) {
          nuevosPrecios.add(PrecioEspecialAdmin(
            idProducto: producto.id,
            idPresentacion: pr.id,
            productoNombre: producto.nombre,
            presentacionDesc: pr.descripcion,
            precioLista: pr.precio,
            precioEspecial: val,
          ));
        }
      }
    }

    provider.saveDescuentosCliente(widget.cliente.id, nuevosPrecios);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final todosProductos = context.watch<AdminProvider>().productos;
    final productos = _filtered(todosProductos);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Precios especiales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: colors.text)),
            Text(widget.cliente.nombre, style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.5)), overflow: TextOverflow.ellipsis),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary, letterSpacing: 0.5)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Hint
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ingresa un precio menor al de lista para activar el descuento. Deja vacío para usar precio de lista.',
                    style: TextStyle(fontSize: 11, color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(color: colors.darkShadow.withValues(alpha: 0.12), blurRadius: 10, offset: const Offset(3, 3)),
                  BoxShadow(color: colors.lightShadow.withValues(alpha: 0.9), blurRadius: 8, offset: const Offset(-3, -3)),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                style: TextStyle(color: colors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Buscar producto o presentación…',
                  hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.4), fontSize: 13),
                  prefixIcon: Icon(Icons.search, color: colors.primary, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: colors.text.withValues(alpha: 0.5), size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          Expanded(
            child: productos.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: colors.text.withValues(alpha: 0.15)),
                        const SizedBox(height: 12),
                        Text('Sin resultados para "$_query"',
                            style: TextStyle(color: colors.text.withValues(alpha: 0.35), fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: productos.length,
              itemBuilder: (context, i) {
                final producto = productos[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: colors.primary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            producto.nombre,
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.text),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            producto.categoria,
                            style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.4)),
                          ),
                        ],
                      ),
                    ),
                    ...producto.presentaciones.map((pr) {
                      final ctrl = _ctrlMap[pr.id]!;
                      return _PrecioEspecialRow(
                        presentacion: pr,
                        controller: ctrl,
                        colors: colors,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        backgroundColor: colors.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Guardar precios', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class _PrecioEspecialRow extends StatefulWidget {
  final PresentacionAdmin presentacion;
  final TextEditingController controller;
  final NeumorphicColors colors;

  const _PrecioEspecialRow({
    required this.presentacion,
    required this.controller,
    required this.colors,
  });

  @override
  State<_PrecioEspecialRow> createState() => _PrecioEspecialRowState();
}

class _PrecioEspecialRowState extends State<_PrecioEspecialRow> {
  bool _hasDiscount = false;

  @override
  void initState() {
    super.initState();
    _hasDiscount = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final val = double.tryParse(widget.controller.text.trim());
    final nowHas = val != null && val > 0 && val < widget.presentacion.precio;
    if (nowHas != _hasDiscount) setState(() => _hasDiscount = nowHas);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final pr = widget.presentacion;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _hasDiscount ? colors.primary.withValues(alpha: 0.06) : colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasDiscount ? colors.primary.withValues(alpha: 0.25) : colors.darkShadow.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          // Info presentación
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pr.descripcion, style: TextStyle(fontWeight: FontWeight.w600, color: colors.text, fontSize: 13)),
                Row(
                  children: [
                    Text('Lista: \$${pr.precio.toStringAsFixed(2)}', style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.45))),
                    if (_hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        '▼ \$${(pr.precio - (double.tryParse(widget.controller.text) ?? 0)).toStringAsFixed(2)} ahorro',
                        style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Campo precio especial
          SizedBox(
            width: 90,
            child: Container(
              decoration: NeumorphicStyle.inset(colors, radius: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: TextField(
                controller: widget.controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: _hasDiscount ? colors.primary : colors.text,
                  fontWeight: _hasDiscount ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Sin desc.',
                  hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.3), fontSize: 12),
                  prefixText: '\$',
                  prefixStyle: TextStyle(color: colors.text.withValues(alpha: 0.5), fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
