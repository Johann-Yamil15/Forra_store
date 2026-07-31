import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forra_store/core/theme/neumorphic_colors.dart';
import 'package:forra_store/core/utils/neumorphic_style.dart';
import 'package:forra_store/presentation/providers/admin_provider.dart';
import 'package:provider/provider.dart';

// ── Estado local de cada presentación ────────────────────────────

class _PresForm {
  final int? id;
  String unidad;
  final TextEditingController cantidadCtrl;
  final TextEditingController precio;
  final TextEditingController stock;
  final TextEditingController stockMinimo;

  _PresForm({
    required this.id,
    required this.unidad,
    required this.cantidadCtrl,
    required this.precio,
    required this.stock,
    required this.stockMinimo,
  });

  factory _PresForm.empty() => _PresForm(
        id: null,
        unidad: 'Kg',
        cantidadCtrl: TextEditingController(),
        precio: TextEditingController(),
        stock: TextEditingController(text: '0'),
        stockMinimo: TextEditingController(text: '5'),
      );

  factory _PresForm.fromExisting(PresentacionAdmin p) => _PresForm(
        id: p.id,
        unidad: p.unidad,
        cantidadCtrl: TextEditingController(text: p.cantidad),
        precio: TextEditingController(text: p.precio.toStringAsFixed(2)),
        stock: TextEditingController(text: p.stock.toString()),
        stockMinimo: TextEditingController(text: p.stockMinimo.toString()),
      );

  void dispose() {
    cantidadCtrl.dispose();
    precio.dispose();
    stock.dispose();
    stockMinimo.dispose();
  }
}

// ════════════════════════════════════════════════════════════════
//  FORMULARIO AGREGAR / EDITAR PRODUCTO
// ════════════════════════════════════════════════════════════════

class ProductoFormScreen extends StatefulWidget {
  final ProductoAdmin? producto;
  const ProductoFormScreen({super.key, this.producto});

  bool get isEditing => producto != null;

  @override
  State<ProductoFormScreen> createState() => _ProductoFormScreenState();
}

class _ProductoFormScreenState extends State<ProductoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _categoriaCtrl;
  late final TextEditingController _subcategoriaCtrl;
  late final TextEditingController _usoCtrl;
  late final TextEditingController _imagenUrlCtrl;

  final List<_PresForm> _presentaciones = [];
  final List<int> _deletedIds = [];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _categoriaCtrl = TextEditingController(text: p?.categoria ?? '');
    _subcategoriaCtrl = TextEditingController(text: p?.subcategoria ?? '');
    _usoCtrl = TextEditingController(text: p?.uso ?? '');
    _imagenUrlCtrl = TextEditingController(text: p?.imagenUrl ?? '');
    if (p != null) {
      for (final pr in p.presentaciones) {
        _presentaciones.add(_PresForm.fromExisting(pr));
      }
    }
    if (_presentaciones.isEmpty) _presentaciones.add(_PresForm.empty());
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _categoriaCtrl.dispose();
    _subcategoriaCtrl.dispose();
    _usoCtrl.dispose();
    _imagenUrlCtrl.dispose();
    for (final f in _presentaciones) {
      f.dispose();
    }
    super.dispose();
  }

  void _addPresentacion() => setState(() => _presentaciones.add(_PresForm.empty()));

  void _removePresentacion(int index) {
    final f = _presentaciones[index];
    if (f.id != null) _deletedIds.add(f.id!);
    setState(() => _presentaciones.removeAt(index));
    f.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    if (_presentaciones.isEmpty) {
      _snack('Agrega al menos una presentación');
      return;
    }

    final provider = context.read<AdminProvider>();
    final nombre = _nombreCtrl.text.trim();
    final descripcion = _descripcionCtrl.text.trim();
    final categoria = _categoriaCtrl.text.trim().isEmpty ? 'Sin categoría' : _categoriaCtrl.text.trim();
    final subcategoria = _subcategoriaCtrl.text.trim();
    final uso = _usoCtrl.text.trim();
    final imagenUrl = _imagenUrlCtrl.text.trim();

    // Persistir categorías y subcategorías nuevas
    if (!provider.categorias.contains(categoria)) provider.addCategoria(categoria);
    if (subcategoria.isNotEmpty && !provider.subcategorias.contains(subcategoria)) {
      provider.addSubcategoria(subcategoria);
    }

    final presLista = _presentaciones.map((f) {
      if (!provider.unidades.contains(f.unidad) && f.unidad.isNotEmpty) {
        provider.addUnidad(f.unidad);
      }
      return PresentacionAdmin(
        id: f.id ?? 0,
        unidad: f.unidad.trim().isEmpty ? 'Kg' : f.unidad,
        cantidad: f.cantidadCtrl.text.trim(),
        precio: double.tryParse(f.precio.text) ?? 0,
        stock: int.tryParse(f.stock.text) ?? 0,
        stockMinimo: int.tryParse(f.stockMinimo.text) ?? 0,
      );
    }).toList();

    if (!widget.isEditing) {
      provider.addProducto(ProductoAdmin(
        id: 0,
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        subcategoria: subcategoria,
        uso: uso,
        imagenUrl: imagenUrl,
        presentaciones: presLista,
      ));
    } else {
      final idP = widget.producto!.id;
      provider.updateProducto(
        idP,
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        subcategoria: subcategoria,
        uso: uso,
        imagenUrl: imagenUrl,
      );
      for (final id in _deletedIds) {
        provider.deletePresentacion(idP, id);
      }
      for (final f in presLista) {
        if (f.id != 0) {
          provider.updatePresentacion(idP, f.id, f);
        } else {
          provider.addPresentacion(idP, f);
        }
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;
    final provider = context.watch<AdminProvider>();

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
          widget.isEditing ? 'Editar Producto' : 'Nuevo Producto',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('GUARDAR', style: TextStyle(fontWeight: FontWeight.w800, color: colors.primary, letterSpacing: 0.5)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Datos generales ──────────────────────────────────
            _sectionLabel('Datos generales', colors),
            const SizedBox(height: 12),
            _fieldLabel('Nombre del producto *', colors),
            const SizedBox(height: 6),
            _textFormField(
              controller: _nombreCtrl,
              hint: 'Ej. Maíz Amarillo',
              colors: colors,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            _fieldLabel('Descripción', colors),
            const SizedBox(height: 6),
            _textFormField(
              controller: _descripcionCtrl,
              hint: 'Descripción breve del producto…',
              colors: colors,
              maxLines: 3,
            ),

            const SizedBox(height: 28),

            // ── Clasificación ────────────────────────────────────
            _sectionLabel('Clasificación', colors),
            const SizedBox(height: 12),
            _fieldLabel('Categoría *', colors),
            const SizedBox(height: 6),
            _AutocompleteField(
              controller: _categoriaCtrl,
              options: provider.categorias,
              hint: 'Alimento, Accesorios, Granos…',
              colors: colors,
              onCreated: (val) => context.read<AdminProvider>().addCategoria(val),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Subcategoría', colors),
            const SizedBox(height: 6),
            _AutocompleteField(
              controller: _subcategoriaCtrl,
              options: provider.subcategorias,
              hint: 'Bovino, Aves, Porcino…',
              colors: colors,
              onCreated: (val) => context.read<AdminProvider>().addSubcategoria(val),
            ),
            const SizedBox(height: 16),
            _fieldLabel('Uso / Aplicación', colors),
            const SizedBox(height: 6),
            _textFormField(
              controller: _usoCtrl,
              hint: 'Ej. Nutrición animal, Fumigación…',
              colors: colors,
            ),

            const SizedBox(height: 28),

            // ── Imagen ───────────────────────────────────────────
            _sectionLabel('Imagen', colors),
            const SizedBox(height: 12),
            _fieldLabel('URL de imagen', colors),
            const SizedBox(height: 6),
            _textFormField(
              controller: _imagenUrlCtrl,
              hint: 'https://ejemplo.com/imagen.jpg',
              colors: colors,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            // Preview reactivo
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _imagenUrlCtrl,
              builder: (context, value, _) {
                final url = value.text.trim();
                if (url.isEmpty) {
                  return Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.08), width: 1.5),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined, color: colors.text.withValues(alpha: 0.2), size: 28),
                          const SizedBox(height: 4),
                          Text('Sin imagen', style: TextStyle(fontSize: 11, color: colors.text.withValues(alpha: 0.25))),
                        ],
                      ),
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.secondary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colors.secondary.withValues(alpha: 0.2)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image_outlined, color: colors.secondary.withValues(alpha: 0.5), size: 28),
                            const SizedBox(height: 4),
                            Text('No se pudo cargar la imagen', style: TextStyle(fontSize: 11, color: colors.secondary.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 28),

            // ── Presentaciones ───────────────────────────────────
            Row(
              children: [
                _sectionLabel('Presentaciones', colors),
                const Spacer(),
                GestureDetector(
                  onTap: _addPresentacion,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 14, color: colors.primary),
                        const SizedBox(width: 4),
                        Text('Agregar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._presentaciones.asMap().entries.map((entry) {
              final idx = entry.key;
              final f = entry.value;
              return _PresentacionFormTile(
                key: ValueKey('pres_$idx'),
                index: idx,
                form: f,
                colors: colors,
                unidades: provider.unidades,
                onUnidadCreated: (val) => context.read<AdminProvider>().addUnidad(val),
                onRemove: _presentaciones.length > 1 ? () => _removePresentacion(idx) : null,
              );
            }),

            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        backgroundColor: colors.primary,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _sectionLabel(String text, NeumorphicColors colors) => Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.45), letterSpacing: 0.5),
      );

  Widget _fieldLabel(String text, NeumorphicColors colors) => Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.45), letterSpacing: 0.4),
      );

  Widget _textFormField({
    required TextEditingController controller,
    required String hint,
    required NeumorphicColors colors,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Container(
      decoration: NeumorphicStyle.inset(colors, radius: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        style: TextStyle(color: colors.text, fontSize: 15),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.3)),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  TILE DE PRESENTACIÓN — con autocomplete de unidad
// ════════════════════════════════════════════════════════════════

class _PresentacionFormTile extends StatefulWidget {
  final int index;
  final _PresForm form;
  final NeumorphicColors colors;
  final List<String> unidades;
  final void Function(String) onUnidadCreated;
  final VoidCallback? onRemove;

  const _PresentacionFormTile({
    super.key,
    required this.index,
    required this.form,
    required this.colors,
    required this.unidades,
    required this.onUnidadCreated,
    this.onRemove,
  });

  @override
  State<_PresentacionFormTile> createState() => _PresentacionFormTileState();
}

class _PresentacionFormTileState extends State<_PresentacionFormTile> {
  late final TextEditingController _unidadCtrl;

  @override
  void initState() {
    super.initState();
    _unidadCtrl = TextEditingController(text: widget.form.unidad);
    _unidadCtrl.addListener(() {
      widget.form.unidad = _unidadCtrl.text;
    });
  }

  @override
  void dispose() {
    _unidadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: NeumorphicStyle.elevated(colors, radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                width: 26, height: 26,
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Center(
                  child: Text('${widget.index + 1}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colors.primary)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Presentación ${widget.index + 1}',
                    style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
              ),
              if (widget.onRemove != null)
                GestureDetector(
                  onTap: widget.onRemove,
                  child: Icon(Icons.delete_outline, color: colors.secondary, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Fila 1: Unidad (autocomplete) + Cantidad/Detalle
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _lbl('Unidad *', colors),
                    const SizedBox(height: 4),
                    _AutocompleteField(
                      controller: _unidadCtrl,
                      options: widget.unidades,
                      hint: 'Kg, Bulto…',
                      colors: colors,
                      onCreated: widget.onUnidadCreated,
                      compact: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 5,
                child: _inlineField('Detalle (opc.)', widget.form.cantidadCtrl, colors,
                    hint: 'Ej. 50 kg, suelto'),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Fila 2: Precio, Stock, Mín
          Row(
            children: [
              Expanded(child: _inlineField('Precio \$', widget.form.precio, colors, hint: '0.00', num: true)),
              const SizedBox(width: 10),
              Expanded(child: _inlineField('Stock', widget.form.stock, colors, hint: '0', num: true, isInt: true)),
              const SizedBox(width: 10),
              Expanded(child: _inlineField('Stock mín.', widget.form.stockMinimo, colors, hint: '5', num: true, isInt: true)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lbl(String text, NeumorphicColors colors) => Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: colors.text.withValues(alpha: 0.45)),
      );

  Widget _inlineField(String label, TextEditingController ctrl, NeumorphicColors colors,
      {String hint = '', bool num = false, bool isInt = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lbl(label, colors),
        const SizedBox(height: 4),
        Container(
          decoration: NeumorphicStyle.inset(colors, radius: 10),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: TextFormField(
            controller: ctrl,
            keyboardType: num
                ? (isInt ? TextInputType.number : const TextInputType.numberWithOptions(decimal: true))
                : TextInputType.text,
            inputFormatters: num
                ? [FilteringTextInputFormatter.allow(isInt ? RegExp(r'\d') : RegExp(r'[\d.]'))]
                : null,
            style: TextStyle(color: colors.text, fontSize: 14),
            validator: num ? (v) => (v == null || v.trim().isEmpty) ? '*' : null : null,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              hintStyle: TextStyle(color: colors.text.withValues(alpha: 0.3), fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  AUTOCOMPLETE CON FILTRO Y OPCIÓN DE CREAR
// ════════════════════════════════════════════════════════════════

class _AutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> options;
  final String hint;
  final NeumorphicColors colors;
  final void Function(String) onCreated;
  final bool compact;

  const _AutocompleteField({
    required this.controller,
    required this.options,
    required this.hint,
    required this.colors,
    required this.onCreated,
    this.compact = false,
  });

  @override
  State<_AutocompleteField> createState() => _AutocompleteFieldState();
}

class _AutocompleteFieldState extends State<_AutocompleteField> {
  final FocusNode _focusNode = FocusNode();

  static const _createPrefix = '➕  ';

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  String _displayFor(String opt) {
    if (opt.startsWith(_createPrefix)) {
      // Extrae: ➕  "valor"  →  valor
      final inner = opt.substring(_createPrefix.length);
      if (inner.length >= 2 && inner.startsWith('"') && inner.endsWith('"')) {
        return inner.substring(1, inner.length - 1);
      }
      return inner;
    }
    return opt;
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focusNode,
      displayStringForOption: _displayFor,
      optionsBuilder: (value) {
        final input = value.text.toLowerCase().trim();
        if (input.isEmpty) return widget.options;
        final filtered = widget.options.where((o) => o.toLowerCase().contains(input)).toList();
        final exactMatch = widget.options.any((o) => o.toLowerCase() == input);
        if (!exactMatch) filtered.add('$_createPrefix"${value.text.trim()}"');
        return filtered;
      },
      onSelected: (opt) {
        if (opt.startsWith(_createPrefix)) {
          final newVal = _displayFor(opt);
          widget.onCreated(newVal);
          widget.controller.text = newVal;
        }
      },
      fieldViewBuilder: (context, ctrl, focusNode, onFieldSubmitted) {
        final h = widget.compact ? 10.0 : 12.0;
        return Container(
          decoration: NeumorphicStyle.inset(widget.colors, radius: 10),
          padding: EdgeInsets.symmetric(horizontal: widget.compact ? 10 : 14, vertical: 2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  focusNode: focusNode,
                  style: TextStyle(color: widget.colors.text, fontSize: widget.compact ? 13 : 15),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: widget.hint,
                    hintStyle: TextStyle(color: widget.colors.text.withValues(alpha: 0.3), fontSize: widget.compact ? 12 : 14),
                    contentPadding: EdgeInsets.symmetric(vertical: h),
                    isDense: widget.compact,
                  ),
                ),
              ),
              Icon(Icons.expand_more_rounded, size: 18, color: widget.colors.text.withValues(alpha: 0.35)),
            ],
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final screenW = MediaQuery.of(context).size.width;
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.only(top: 4),
              width: screenW - 40,
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: widget.colors.background,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: widget.colors.darkShadow.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                children: options.map((opt) {
                  final isCreate = opt.startsWith(_createPrefix);
                  return InkWell(
                    onTap: () => onSelected(opt),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      child: Row(
                        children: [
                          Icon(
                            isCreate ? Icons.add_circle_outline : Icons.label_outline,
                            size: 15,
                            color: isCreate ? widget.colors.primary : widget.colors.text.withValues(alpha: 0.35),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isCreate ? _displayFor(opt) : opt,
                              style: TextStyle(
                                fontSize: 13,
                                color: isCreate ? widget.colors.primary : widget.colors.text,
                                fontWeight: isCreate ? FontWeight.w700 : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isCreate)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: widget.colors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('NUEVO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: widget.colors.primary)),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  BOTTOM SHEET: REABASTECER STOCK
// ════════════════════════════════════════════════════════════════

class ProductoRestockSheet extends StatefulWidget {
  final ProductoAdmin producto;
  const ProductoRestockSheet({super.key, required this.producto});

  @override
  State<ProductoRestockSheet> createState() => _ProductoRestockSheetState();
}

class _ProductoRestockSheetState extends State<ProductoRestockSheet> {
  late final Map<int, TextEditingController> _ctrlMap;

  @override
  void initState() {
    super.initState();
    _ctrlMap = {
      for (final p in widget.producto.presentaciones)
        p.id: TextEditingController(text: '0'),
    };
  }

  @override
  void dispose() {
    for (final c in _ctrlMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _apply() {
    final provider = context.read<AdminProvider>();
    for (final entry in _ctrlMap.entries) {
      final cantidad = int.tryParse(entry.value.text) ?? 0;
      if (cantidad > 0) {
        provider.addStock(widget.producto.id, entry.key, cantidad);
      }
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? NeumorphicColors.dark : NeumorphicColors.light;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: colors.text.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: colors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.add_box_outlined, color: colors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Reabastecer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colors.text)),
                    Text(widget.producto.nombre, style: TextStyle(fontSize: 12, color: colors.text.withValues(alpha: 0.5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...widget.producto.presentaciones.map((pr) {
            final ctrl = _ctrlMap[pr.id]!;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: NeumorphicStyle.elevated(colors, radius: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pr.descripcion, style: TextStyle(fontWeight: FontWeight.bold, color: colors.text)),
                        Text('Stock actual: ${pr.stock}',
                            style: TextStyle(fontSize: 11, color: pr.enAlerta ? colors.secondary : colors.text.withValues(alpha: 0.45))),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _QtyBtn(icon: Icons.remove, colors: colors, onTap: () {
                        final v = int.tryParse(ctrl.text) ?? 0;
                        if (v > 0) ctrl.text = '${v - 1}';
                      }),
                      SizedBox(
                        width: 48,
                        child: TextField(
                          controller: ctrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(fontWeight: FontWeight.bold, color: colors.text),
                          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        ),
                      ),
                      _QtyBtn(icon: Icons.add, colors: colors, onTap: () {
                        final v = int.tryParse(ctrl.text) ?? 0;
                        ctrl.text = '${v + 1}';
                      }),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Aplicar reabastecimiento',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final NeumorphicColors colors;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: NeumorphicStyle.elevated(colors, radius: 8, depth: 3),
        child: Icon(icon, size: 16, color: colors.primary),
      ),
    );
  }
}
