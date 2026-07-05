import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/finanza.dart';
import 'finanzas_repository.dart';

class FinanzasScreen extends StatefulWidget {
  const FinanzasScreen({super.key});

  @override
  State<FinanzasScreen> createState() => _FinanzasScreenState();
}

class _FinanzasScreenState extends State<FinanzasScreen>
    with SingleTickerProviderStateMixin {
  final _repo = FinanzasRepository();
  late TabController _tabController;
  List<MovimientoFinanciero> _movimientos = [];
  bool _cargando = true;
  final _currency = NumberFormat.currency(locale: 'es_AR', symbol: r'$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final movimientos = await _repo.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _movimientos = movimientos;
      _cargando = false;
    });
  }

  Future<void> _agregarMovimiento(String tipo) async {
    final resultado = await showDialog<MovimientoFinanciero>(
      context: context,
      builder: (_) => _MovimientoDialog(tipo: tipo),
    );
    if (resultado != null) {
      await _repo.crear(resultado);
      _cargar();
    }
  }

  Future<void> _eliminarMovimiento(MovimientoFinanciero mov) async {
    await _repo.eliminar(mov.id!);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ingresos = _movimientos.where((m) => m.tipo == 'ingreso').toList();
    final egresos = _movimientos.where((m) => m.tipo == 'egreso').toList();
    final totalIngresos = ingresos.fold<double>(0, (s, m) => s + m.monto);
    final totalEgresos = egresos.fold<double>(0, (s, m) => s + m.monto);
    final balance = totalIngresos - totalEgresos;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('💰 Finanzas', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: _ResumenTarjeta(
                      label: 'Ingresos',
                      valor: _currency.format(totalIngresos),
                      color: AppColors.success)),
              const SizedBox(width: 16),
              Expanded(
                  child: _ResumenTarjeta(
                      label: 'Egresos',
                      valor: _currency.format(totalEgresos),
                      color: AppColors.danger)),
              const SizedBox(width: 16),
              Expanded(
                  child: _ResumenTarjeta(
                      label: 'Balance',
                      valor: _currency.format(balance),
                      color: balance >= 0
                          ? AppColors.primaryGreen
                          : AppColors.danger)),
            ],
          ),
          const SizedBox(height: 20),
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColors.primaryGreen,
            tabs: const [Tab(text: 'Ingresos'), Tab(text: 'Egresos')],
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _ListaMovimientos(
                        movimientos: ingresos,
                        tipo: 'ingreso',
                        currency: _currency,
                        onAgregar: () => _agregarMovimiento('ingreso'),
                        onEliminar: _eliminarMovimiento,
                      ),
                      _ListaMovimientos(
                        movimientos: egresos,
                        tipo: 'egreso',
                        currency: _currency,
                        onAgregar: () => _agregarMovimiento('egreso'),
                        onEliminar: _eliminarMovimiento,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ResumenTarjeta extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;
  const _ResumenTarjeta(
      {required this.label, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(valor,
              style: TextStyle(
                  color: color, fontSize: 20, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ListaMovimientos extends StatelessWidget {
  final List<MovimientoFinanciero> movimientos;
  final String tipo;
  final NumberFormat currency;
  final VoidCallback onAgregar;
  final ValueChanged<MovimientoFinanciero> onEliminar;

  const _ListaMovimientos({
    required this.movimientos,
    required this.tipo,
    required this.currency,
    required this.onAgregar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: onAgregar,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(tipo == 'ingreso' ? 'Nuevo ingreso' : 'Nuevo egreso'),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: movimientos.isEmpty
                ? Center(
                    child: Text('Sin movimientos registrados',
                        style: Theme.of(context).textTheme.bodyMedium))
                : ListView.separated(
                    itemCount: movimientos.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final m = movimientos[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(m.concepto),
                        subtitle: Text(
                            '${m.categoria ?? 'Sin categoría'} · ${dateFmt.format(m.fecha)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              currency.format(m.monto),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: tipo == 'ingreso'
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  size: 20),
                              onPressed: () => onEliminar(m),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MovimientoDialog extends StatefulWidget {
  final String tipo;
  const _MovimientoDialog({required this.tipo});

  @override
  State<_MovimientoDialog> createState() => _MovimientoDialogState();
}

class _MovimientoDialogState extends State<_MovimientoDialog> {
  final _conceptoCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  final _obsCtrl = TextEditingController();
  String? _categoria;
  DateTime _fecha = DateTime.now();
  String? _error;

  void _intentarGuardar() {
    final monto = double.tryParse(_montoCtrl.text.replaceAll(',', '.'));
    if (_conceptoCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ingresá un concepto.');
      return;
    }
    if (monto == null) {
      setState(() => _error = 'Ingresá un monto válido.');
      return;
    }
    Navigator.pop(
      context,
      MovimientoFinanciero(
        tipo: widget.tipo,
        fecha: _fecha,
        concepto: _conceptoCtrl.text.trim(),
        categoria: _categoria,
        monto: monto,
        observaciones:
            _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.tipo == 'ingreso'
        ? CategoriasFinanzas.ingresos
        : CategoriasFinanzas.egresos;

    return AlertDialog(
      title: Text(widget.tipo == 'ingreso' ? 'Nuevo ingreso' : 'Nuevo egreso'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _conceptoCtrl,
              decoration: const InputDecoration(labelText: 'Concepto'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _montoCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Monto'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(labelText: 'Categoría'),
              items: categorias
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _categoria = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _obsCtrl,
              decoration: const InputDecoration(labelText: 'Observaciones'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
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
          onPressed: _intentarGuardar,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
