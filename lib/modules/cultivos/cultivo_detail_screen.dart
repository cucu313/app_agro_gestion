import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lote.dart';
import 'lotes_repository.dart';
import 'cultivo_form_screen.dart';

class CultivoDetailScreen extends StatefulWidget {
  final Lote lote;
  const CultivoDetailScreen({super.key, required this.lote});

  @override
  State<CultivoDetailScreen> createState() => _CultivoDetailScreenState();
}

class _CultivoDetailScreenState extends State<CultivoDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = LotesRepository();
  late TabController _tabController;
  late Lote _lote;
  List<LoteLabor> _labores = [];
  bool _cargando = true;

  final _tipos = const {
    'fertilizacion': ('Fertilizaciones', Icons.eco_rounded),
    'aplicacion': ('Aplicaciones', Icons.science_rounded),
    'riego': ('Riegos', Icons.water_drop_rounded),
    'produccion': ('Producción', Icons.inventory_2_rounded),
  };

  @override
  void initState() {
    super.initState();
    _lote = widget.lote;
    _tabController = TabController(length: _tipos.length, vsync: this);
    _cargarLabores();
  }

  Future<void> _cargarLabores() async {
    setState(() => _cargando = true);
    final labores = await _repo.obtenerLabores(_lote.id!);
    if (!mounted) return;
    setState(() {
      _labores = labores;
      _cargando = false;
    });
  }

  Future<void> _editarLote() async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CultivoFormScreen(lote: _lote)),
    );
    if (resultado == true) {
      final actualizado = await _repo.obtenerPorId(_lote.id!);
      if (actualizado != null && mounted) {
        setState(() => _lote = actualizado);
      }
    }
  }

  Future<void> _eliminarLote() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar lote'),
        content: Text('¿Eliminar "${_lote.nombre}" y todo su historial? Esta acción no se puede deshacer.'),
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
      await _repo.eliminar(_lote.id!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _agregarLabor(String tipo) async {
    final resultado = await showDialog<LoteLabor>(
      context: context,
      builder: (_) => _LaborDialog(tipo: tipo, loteId: _lote.id!),
    );
    if (resultado != null) {
      await _repo.crearLabor(resultado);
      _cargarLabores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_lote.nombre),
        actions: [
          IconButton(
              onPressed: _editarLote, icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: _eliminarLote,
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
                _DatoLote(label: 'Cultivo', valor: _lote.tipoCultivo ?? '—'),
                _DatoLote(
                    label: 'Superficie',
                    valor: _lote.superficie != null
                        ? '${_lote.superficie} ha'
                        : '—'),
                _DatoLote(
                    label: 'Siembra',
                    valor: _lote.fechaSiembra != null
                        ? dateFmt.format(_lote.fechaSiembra!)
                        : '—'),
                _DatoLote(
                    label: 'Cosecha estimada',
                    valor: _lote.fechaCosechaEstimada != null
                        ? dateFmt.format(_lote.fechaCosechaEstimada!)
                        : '—'),
                _DatoLote(label: 'Estado', valor: _lote.estado),
              ],
            ),
          ),
          if (_lote.observaciones != null && _lote.observaciones!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(_lote.observaciones!, style: theme.textTheme.bodyMedium),
            ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryGreen,
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
                          _labores.where((l) => l.tipo == tipo).toList();
                      return _ListaLabores(
                        tipo: tipo,
                        registros: registros,
                        onAgregar: () => _agregarLabor(tipo),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DatoLote extends StatelessWidget {
  final String label;
  final String valor;
  const _DatoLote({required this.label, required this.valor});

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

class _ListaLabores extends StatelessWidget {
  final String tipo;
  final List<LoteLabor> registros;
  final VoidCallback onAgregar;

  const _ListaLabores({
    required this.tipo,
    required this.registros,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
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
                        title: Text(r.producto ?? tipo),
                        subtitle: Text([
                          if (r.dosis != null) 'Dosis: ${r.dosis}',
                          if (r.cantidad != null)
                            'Cantidad: ${r.cantidad} ${r.unidad ?? ''}',
                          if (r.observaciones != null) r.observaciones!,
                        ].join(' · ')),
                        trailing: Text(dateFmt.format(r.fecha)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LaborDialog extends StatefulWidget {
  final String tipo;
  final int loteId;
  const _LaborDialog({required this.tipo, required this.loteId});

  @override
  State<_LaborDialog> createState() => _LaborDialogState();
}

class _LaborDialogState extends State<_LaborDialog> {
  final _productoCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _cantidadCtrl = TextEditingController();
  final _unidadCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo registro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _productoCtrl,
              decoration: const InputDecoration(labelText: 'Producto / detalle'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _cantidadCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unidadCtrl,
                    decoration: const InputDecoration(labelText: 'Unidad'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dosisCtrl,
              decoration: const InputDecoration(labelText: 'Dosis'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              decoration: const InputDecoration(labelText: 'Observaciones'),
            ),
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
              LoteLabor(
                loteId: widget.loteId,
                tipo: widget.tipo,
                fecha: _fecha,
                producto: _productoCtrl.text.trim().isEmpty
                    ? null
                    : _productoCtrl.text.trim(),
                dosis: _dosisCtrl.text.trim().isEmpty
                    ? null
                    : _dosisCtrl.text.trim(),
                cantidad: double.tryParse(_cantidadCtrl.text.replaceAll(',', '.')),
                unidad: _unidadCtrl.text.trim().isEmpty
                    ? null
                    : _unidadCtrl.text.trim(),
                observaciones:
                    _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
