import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/lote.dart';
import 'lotes_repository.dart';

class CultivoFormScreen extends StatefulWidget {
  final Lote? lote;
  const CultivoFormScreen({super.key, this.lote});

  @override
  State<CultivoFormScreen> createState() => _CultivoFormScreenState();
}

class _CultivoFormScreenState extends State<CultivoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = LotesRepository();
  final _dateFmt = DateFormat('dd/MM/yyyy');

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _numeroCtrl;
  late final TextEditingController _superficieCtrl;
  late final TextEditingController _tipoCultivoCtrl;
  late final TextEditingController _observacionesCtrl;

  DateTime? _fechaSiembra;
  DateTime? _fechaCosecha;
  String _estado = 'Sembrado';

  final _estados = const ['Sembrado', 'En crecimiento', 'Cosechado'];

  bool get _esEdicion => widget.lote != null;

  @override
  void initState() {
    super.initState();
    final l = widget.lote;
    _nombreCtrl = TextEditingController(text: l?.nombre ?? '');
    _numeroCtrl = TextEditingController(text: l?.numero ?? '');
    _superficieCtrl =
        TextEditingController(text: l?.superficie?.toString() ?? '');
    _tipoCultivoCtrl = TextEditingController(text: l?.tipoCultivo ?? '');
    _observacionesCtrl = TextEditingController(text: l?.observaciones ?? '');
    _fechaSiembra = l?.fechaSiembra;
    _fechaCosecha = l?.fechaCosechaEstimada;
    _estado = l?.estado ?? 'Sembrado';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _numeroCtrl.dispose();
    _superficieCtrl.dispose();
    _tipoCultivoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool esSiembra) async {
    final inicial =
        (esSiembra ? _fechaSiembra : _fechaCosecha) ?? DateTime.now();
    final fecha = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (fecha == null) return;
    setState(() {
      if (esSiembra) {
        _fechaSiembra = fecha;
      } else {
        _fechaCosecha = fecha;
      }
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final lote = Lote(
      id: widget.lote?.id,
      nombre: _nombreCtrl.text.trim(),
      numero: _numeroCtrl.text.trim().isEmpty ? null : _numeroCtrl.text.trim(),
      superficie: double.tryParse(_superficieCtrl.text.replaceAll(',', '.')),
      tipoCultivo:
          _tipoCultivoCtrl.text.trim().isEmpty ? null : _tipoCultivoCtrl.text.trim(),
      fechaSiembra: _fechaSiembra,
      fechaCosechaEstimada: _fechaCosecha,
      estado: _estado,
      observaciones: _observacionesCtrl.text.trim().isEmpty
          ? null
          : _observacionesCtrl.text.trim(),
      creadoEn: widget.lote?.creadoEn,
    );

    if (_esEdicion) {
      await _repo.actualizar(lote);
    } else {
      await _repo.crear(lote);
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar lote' : 'Nuevo lote'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del lote'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _numeroCtrl,
                          decoration: const InputDecoration(labelText: 'Número'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _superficieCtrl,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Superficie (ha)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _tipoCultivoCtrl,
                    decoration: const InputDecoration(labelText: 'Tipo de cultivo'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectorFecha(
                          label: 'Fecha de siembra',
                          fecha: _fechaSiembra,
                          formato: _dateFmt,
                          onTap: () => _seleccionarFecha(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _SelectorFecha(
                          label: 'Cosecha estimada',
                          fecha: _fechaCosecha,
                          formato: _dateFmt,
                          onTap: () => _seleccionarFecha(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _estado,
                    decoration: const InputDecoration(labelText: 'Estado'),
                    items: _estados
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => setState(() => _estado = v ?? _estado),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _observacionesCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Observaciones'),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _guardar,
                    child: Text(_esEdicion ? 'Guardar cambios' : 'Crear lote'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectorFecha extends StatelessWidget {
  final String label;
  final DateTime? fecha;
  final DateFormat formato;
  final VoidCallback onTap;

  const _SelectorFecha({
    required this.label,
    required this.fecha,
    required this.formato,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          fecha != null ? formato.format(fecha!) : 'Seleccionar',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}
