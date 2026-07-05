import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/maquinaria.dart';
import 'maquinaria_repository.dart';
import 'maquinaria_form_screen.dart';

class MaquinariaDetailScreen extends StatefulWidget {
  final Maquinaria maquinaria;
  const MaquinariaDetailScreen({super.key, required this.maquinaria});

  @override
  State<MaquinariaDetailScreen> createState() =>
      _MaquinariaDetailScreenState();
}

class _MaquinariaDetailScreenState extends State<MaquinariaDetailScreen>
    with SingleTickerProviderStateMixin {
  final _repo = MaquinariaRepository();
  late TabController _tabController;
  late Maquinaria _maquinaria;
  List<MaquinariaMantenimiento> _registros = [];
  bool _cargando = true;

  final _tipos = const {
    'mantenimiento': ('Mantenimientos', Icons.build_rounded),
    'cambio_aceite': ('Cambios de aceite', Icons.oil_barrel_rounded),
    'reparacion': ('Reparaciones', Icons.construction_rounded),
    'combustible': ('Combustible', Icons.local_gas_station_rounded),
  };

  @override
  void initState() {
    super.initState();
    _maquinaria = widget.maquinaria;
    _tabController = TabController(length: _tipos.length, vsync: this);
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    setState(() => _cargando = true);
    final registros = await _repo.obtenerMantenimientos(_maquinaria.id!);
    if (!mounted) return;
    setState(() {
      _registros = registros;
      _cargando = false;
    });
  }

  Future<void> _editar() async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => MaquinariaFormScreen(maquinaria: _maquinaria)),
    );
    if (resultado == true) {
      final actualizado = await _repo.obtenerPorId(_maquinaria.id!);
      if (actualizado != null && mounted) {
        setState(() => _maquinaria = actualizado);
      }
    }
  }

  Future<void> _eliminar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar máquina'),
        content: Text(
            '¿Eliminar "${_maquinaria.nombre}" y todo su historial? Esta acción no se puede deshacer.'),
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
      await _repo.eliminar(_maquinaria.id!);
      if (mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _agregarRegistro(String tipo) async {
    final resultado = await showDialog<MaquinariaMantenimiento>(
      context: context,
      builder: (_) => _MantenimientoDialog(tipo: tipo, maquinariaId: _maquinaria.id!),
    );
    if (resultado != null) {
      await _repo.crearMantenimiento(resultado);
      _cargarRegistros();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(_maquinaria.nombre),
        actions: [
          IconButton(onPressed: _editar, icon: const Icon(Icons.edit_rounded)),
          IconButton(
              onPressed: _eliminar,
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
                _Dato(label: 'Marca', valor: _maquinaria.marca ?? '—'),
                _Dato(label: 'Modelo', valor: _maquinaria.modelo ?? '—'),
                _Dato(
                    label: 'Año',
                    valor: _maquinaria.anio?.toString() ?? '—'),
                _Dato(
                    label: 'Horas de uso',
                    valor: '${_maquinaria.horasUso.toStringAsFixed(0)} hs'),
                _Dato(label: 'Estado', valor: _maquinaria.estado),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.maquinaria,
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
                          _registros.where((r) => r.tipo == tipo).toList();
                      return _ListaRegistros(
                        registros: registros,
                        onAgregar: () => _agregarRegistro(tipo),
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

class _ListaRegistros extends StatelessWidget {
  final List<MaquinariaMantenimiento> registros;
  final VoidCallback onAgregar;
  const _ListaRegistros({required this.registros, required this.onAgregar});

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
                        title: Text(r.descripcion ?? '—'),
                        subtitle: Text([
                          dateFmt.format(r.fecha),
                          if (r.proximoServicio != null)
                            'Próximo servicio: ${dateFmt.format(r.proximoServicio!)}',
                        ].join(' · ')),
                        trailing: r.costo != null
                            ? Text(currency.format(r.costo),
                                style: const TextStyle(fontWeight: FontWeight.w600))
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

class _MantenimientoDialog extends StatefulWidget {
  final String tipo;
  final int maquinariaId;
  const _MantenimientoDialog({required this.tipo, required this.maquinariaId});

  @override
  State<_MantenimientoDialog> createState() => _MantenimientoDialogState();
}

class _MantenimientoDialogState extends State<_MantenimientoDialog> {
  final _descripcionCtrl = TextEditingController();
  final _costoCtrl = TextEditingController();
  DateTime _fecha = DateTime.now();
  DateTime? _proximoServicio;
  final _dateFmt = DateFormat('dd/MM/yyyy');

  Future<void> _seleccionarProximoServicio() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => _proximoServicio = fecha);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo registro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descripcionCtrl,
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _costoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo'),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _seleccionarProximoServicio,
              child: InputDecorator(
                decoration:
                    const InputDecoration(labelText: 'Próximo servicio (opcional)'),
                child: Text(_proximoServicio != null
                    ? _dateFmt.format(_proximoServicio!)
                    : 'Seleccionar'),
              ),
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
              MaquinariaMantenimiento(
                maquinariaId: widget.maquinariaId,
                tipo: widget.tipo,
                fecha: _fecha,
                descripcion: _descripcionCtrl.text.trim().isEmpty
                    ? null
                    : _descripcionCtrl.text.trim(),
                costo: double.tryParse(_costoCtrl.text.replaceAll(',', '.')),
                proximoServicio: _proximoServicio,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
