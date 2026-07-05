import 'package:flutter/material.dart';
import '../../models/maquinaria.dart';
import 'maquinaria_repository.dart';

class MaquinariaFormScreen extends StatefulWidget {
  final Maquinaria? maquinaria;
  const MaquinariaFormScreen({super.key, this.maquinaria});

  @override
  State<MaquinariaFormScreen> createState() => _MaquinariaFormScreenState();
}

class _MaquinariaFormScreenState extends State<MaquinariaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = MaquinariaRepository();

  late final TextEditingController _nombreCtrl;
  late final TextEditingController _marcaCtrl;
  late final TextEditingController _modeloCtrl;
  late final TextEditingController _anioCtrl;
  late final TextEditingController _horasCtrl;

  String _estado = 'Operativo';
  final _estados = const ['Operativo', 'En reparación', 'Fuera de servicio'];

  bool get _esEdicion => widget.maquinaria != null;

  @override
  void initState() {
    super.initState();
    final m = widget.maquinaria;
    _nombreCtrl = TextEditingController(text: m?.nombre ?? '');
    _marcaCtrl = TextEditingController(text: m?.marca ?? '');
    _modeloCtrl = TextEditingController(text: m?.modelo ?? '');
    _anioCtrl = TextEditingController(text: m?.anio?.toString() ?? '');
    _horasCtrl = TextEditingController(text: m?.horasUso.toString() ?? '0');
    _estado = m?.estado ?? 'Operativo';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _marcaCtrl.dispose();
    _modeloCtrl.dispose();
    _anioCtrl.dispose();
    _horasCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final maquinaria = Maquinaria(
      id: widget.maquinaria?.id,
      nombre: _nombreCtrl.text.trim(),
      marca: _marcaCtrl.text.trim().isEmpty ? null : _marcaCtrl.text.trim(),
      modelo: _modeloCtrl.text.trim().isEmpty ? null : _modeloCtrl.text.trim(),
      anio: int.tryParse(_anioCtrl.text.trim()),
      horasUso: double.tryParse(_horasCtrl.text.replaceAll(',', '.')) ?? 0,
      estado: _estado,
      creadoEn: widget.maquinaria?.creadoEn,
    );

    if (_esEdicion) {
      await _repo.actualizar(maquinaria);
    } else {
      await _repo.crear(maquinaria);
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
        title: Text(_esEdicion ? 'Editar máquina' : 'Nueva máquina'),
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
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _marcaCtrl,
                          decoration: const InputDecoration(labelText: 'Marca'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _modeloCtrl,
                          decoration: const InputDecoration(labelText: 'Modelo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _anioCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Año'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _horasCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Horas de uso'),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardar,
                    child: Text(_esEdicion ? 'Guardar cambios' : 'Registrar máquina'),
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
