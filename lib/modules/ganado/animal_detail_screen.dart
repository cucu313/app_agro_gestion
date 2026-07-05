import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/animal.dart';
import 'animales_repository.dart';
import 'animal_form_screen.dart';

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = AnimalesRepository();
  late TabController _tabController;
  late Animal _animal;
  List<AnimalEvento> _eventos = [];
  bool _cargando = true;

  final _tipos = const {
    'vacuna': ('Vacunas', Icons.vaccines_rounded),
    'tratamiento': ('Tratamientos', Icons.healing_rounded),
    'reproduccion': ('Reproducción', Icons.favorite_rounded),
    'compra': ('Compras', Icons.shopping_cart_rounded),
    'venta': ('Ventas', Icons.sell_rounded),
    'fallecimiento': ('Fallecimiento', Icons.report_rounded),
    'observacion': ('Observaciones', Icons.notes_rounded),
  };

  @override
  void initState() {
    super.initState();
    _animal = widget.animal;
    _tabController = TabController(length: _tipos.length, vsync: this);
    _cargarEventos();
  }

  Future<void> _cargarEventos() async {
    setState(() => _cargando = true);
    final eventos = await _repo.obtenerEventos(_animal.id!);
    if (!mounted) return;
    setState(() {
      _eventos = eventos;
      _cargando = false;
    });
  }

  Future<void> _editarAnimal() async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AnimalFormScreen(animal: _animal)),
    );
    if (resultado == true) {
      final actualizado = await _repo.obtenerPorId(_animal.id!);
      if (actualizado != null && mounted) setState(() => _animal = actualizado);
    }
  }

  Future<void> _eliminarAnimal() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar animal'),
        content: Text(
            '¿Eliminar el registro de "${_animal.caravana}" y todo su historial? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmar == true) {
      await _repo.eliminar(_animal.id!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _agregarEvento(String tipo) async {
    final resultado = await showDialog<AnimalEvento>(
      context: context,
      builder: (_) => _EventoDialog(tipo: tipo, animalId: _animal.id!),
    );
    if (resultado != null) {
      await _repo.crearEvento(resultado);
      _cargarEventos();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_animal.nombre?.isNotEmpty == true
            ? _animal.nombre!
            : 'Caravana ${_animal.caravana}'),
        actions: [
          IconButton(
              onPressed: _editarAnimal, icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: _eliminarAnimal,
              icon: const Icon(Icons.delete_outline_rounded)),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Wrap(
              spacing: 24,
              runSpacing: 12,
              children: [
                _Dato(label: 'Caravana', valor: _animal.caravana),
                _Dato(label: 'Sexo', valor: _animal.sexo ?? '—'),
                _Dato(label: 'Raza', valor: _animal.raza ?? '—'),
                _Dato(
                    label: 'Peso',
                    valor: _animal.peso != null ? '${_animal.peso} kg' : '—'),
                _Dato(
                  label: 'Nacimiento',
                  valor: _animal.fechaNacimiento != null
                      ? dateFmt.format(_animal.fechaNacimiento!)
                      : '—',
                ),
                _Dato(
                    label: 'Estado sanitario',
                    valor: _animal.estadoSanitario ?? '—'),
                _Dato(label: 'Activo', valor: _animal.activo ? 'Sí' : 'No'),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.ganado,
            tabs: _tipos.values
                .map((v) => Tab(text: v.$1, icon: Icon(v.$2, size: 18)))
                .toList(),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: _tipos.keys.map((tipo) {
                      final registros =
                          _eventos.where((e) => e.tipo == tipo).toList();
                      return _ListaEventos(
                        registros: registros,
                        onAgregar: () => _agregarEvento(tipo),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  final String label;
  final String valor;
  const _Dato({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 2),
        Text(valor, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ListaEventos extends StatelessWidget {
  final List<AnimalEvento> registros;
  final VoidCallback onAgregar;

  const _ListaEventos({required this.registros, required this.onAgregar});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: r'$');
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Agregar registro'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: registros.isEmpty
                ? Center(
                    child: Text('Sin registros todavía',
                        style: Theme.of(context).textTheme.bodyMedium))
                : ListView.separated(
                    itemCount: registros.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final r = registros[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(r.detalle ?? '—'),
                        subtitle: Text(dateFmt.format(r.fecha)),
                        trailing: r.monto != null
                            ? Text(currency.format(r.monto),
                                style:
                                    const TextStyle(fontWeight: FontWeight.w600))
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventoDialog extends StatefulWidget {
  final String tipo;
  final int animalId;
  const _EventoDialog({required this.tipo, required this.animalId});

  @override
  State<_EventoDialog> createState() => _EventoDialogState();
}

class _EventoDialogState extends State<_EventoDialog> {
  final _detalleCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  bool get _requiereMonto => widget.tipo == 'compra' || widget.tipo == 'venta';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo registro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _detalleCtrl,
              decoration: const InputDecoration(labelText: 'Detalle'),
              maxLines: 2,
            ),
            if (_requiereMonto) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _montoCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(
              context,
              AnimalEvento(
                animalId: widget.animalId,
                tipo: widget.tipo,
                fecha: _fecha,
                detalle:
                    _detalleCtrl.text.trim().isEmpty ? null : _detalleCtrl.text.trim(),
                monto: double.tryParse(_montoCtrl.text.replaceAll(',', '.')),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
