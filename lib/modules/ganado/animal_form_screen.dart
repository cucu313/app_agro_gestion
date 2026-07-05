import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/animal.dart';
import 'animales_repository.dart';

class AnimalFormScreen extends StatefulWidget {
  final Animal? animal;
  const AnimalFormScreen({super.key, this.animal});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = AnimalesRepository();
  final _dateFmt = DateFormat('dd/MM/yyyy');

  late final TextEditingController _caravanaCtrl;
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _razaCtrl;
  late final TextEditingController _pesoCtrl;
  late final TextEditingController _estadoSanitarioCtrl;

  String? _sexo;
  DateTime? _fechaNacimiento;
  bool _activo = true;

  bool get _esEdicion => widget.animal != null;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _caravanaCtrl = TextEditingController(text: a?.caravana ?? '');
    _nombreCtrl = TextEditingController(text: a?.nombre ?? '');
    _razaCtrl = TextEditingController(text: a?.raza ?? '');
    _pesoCtrl = TextEditingController(text: a?.peso?.toString() ?? '');
    _estadoSanitarioCtrl =
        TextEditingController(text: a?.estadoSanitario ?? '');
    _sexo = a?.sexo;
    _fechaNacimiento = a?.fechaNacimiento;
    _activo = a?.activo ?? true;
  }

  @override
  void dispose() {
    _caravanaCtrl.dispose();
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _pesoCtrl.dispose();
    _estadoSanitarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (fecha != null) setState(() => _fechaNacimiento = fecha);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final animal = Animal(
      id: widget.animal?.id,
      caravana: _caravanaCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim().isEmpty ? null : _nombreCtrl.text.trim(),
      sexo: _sexo,
      raza: _razaCtrl.text.trim().isEmpty ? null : _razaCtrl.text.trim(),
      fechaNacimiento: _fechaNacimiento,
      peso: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')),
      estadoSanitario: _estadoSanitarioCtrl.text.trim().isEmpty
          ? null
          : _estadoSanitarioCtrl.text.trim(),
      activo: _activo,
      creadoEn: widget.animal?.creadoEn,
    );

    if (_esEdicion) {
      await _repo.actualizar(animal);
    } else {
      await _repo.crear(animal);
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
        title: Text(_esEdicion ? 'Editar animal' : 'Nuevo animal'),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _caravanaCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Número de caravana'),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Requerido'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _nombreCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Nombre (opcional)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _sexo,
                          decoration: const InputDecoration(labelText: 'Sexo'),
                          items: const [
                            DropdownMenuItem(
                                value: 'Macho', child: Text('Macho')),
                            DropdownMenuItem(
                                value: 'Hembra', child: Text('Hembra')),
                          ],
                          onChanged: (v) => setState(() => _sexo = v),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _razaCtrl,
                          decoration: const InputDecoration(labelText: 'Raza'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _seleccionarFecha,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                                labelText: 'Fecha de nacimiento'),
                            child: Text(
                              _fechaNacimiento != null
                                  ? _dateFmt.format(_fechaNacimiento!)
                                  : 'Seleccionar',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _pesoCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration:
                              const InputDecoration(labelText: 'Peso (kg)'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _estadoSanitarioCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Estado sanitario'),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Animal activo en el rodeo'),
                    subtitle: const Text(
                        'Desactivalo si el animal fue vendido, murió o ya no está en el establecimiento'),
                    value: _activo,
                    onChanged: (v) => setState(() => _activo = v),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _guardar,
                    child: Text(_esEdicion ? 'Guardar cambios' : 'Registrar animal'),
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
