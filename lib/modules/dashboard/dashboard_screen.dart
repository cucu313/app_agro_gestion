import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/stat_card.dart';
import '../cultivos/lotes_repository.dart';
import '../finanzas/finanzas_repository.dart';
import '../calendario/calendario_repository.dart';
import '../../models/evento_calendario.dart';
import '../../core/database/database_helper.dart';

/// Pantalla de inicio: resumen general de la explotación.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _lotesRepo = LotesRepository();
  final _finanzasRepo = FinanzasRepository();
  final _calendarioRepo = CalendarioRepository();

  bool _cargando = true;
  int _cultivosActivos = 0;
  int _cantidadAnimales = 0;
  double _gastosMes = 0;
  double _ingresosMes = 0;
  List<EventoCalendario> _proximasTareas = [];

  final _currency = NumberFormat.currency(locale: 'es_AR', symbol: r'$');

  @override
  void initState() {
    super.initState();
    _cargarResumen();
  }

  Future<void> _cargarResumen() async {
    final db = await DatabaseHelper.instance.database;
    final ahora = DateTime.now();
    final inicioMes = DateTime(ahora.year, ahora.month, 1);
    final finMes = DateTime(ahora.year, ahora.month + 1, 0, 23, 59, 59);

    final cultivosActivos = await _lotesRepo.contarActivos();
    final animales = await db.rawQuery(
      "SELECT COUNT(*) as total FROM animales WHERE activo = 1",
    );
    final (ingresos, egresos) =
        await _finanzasRepo.totalesPorRango(inicioMes, finMes);
    final proximasTareas = await _calendarioRepo.obtenerProximos(limite: 4);

    if (!mounted) return;
    setState(() {
      _cultivosActivos = cultivosActivos;
      _cantidadAnimales = (animales.first['total'] as int?) ?? 0;
      _ingresosMes = ingresos;
      _gastosMes = egresos;
      _proximasTareas = proximasTareas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = _ingresosMes - _gastosMes;

    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _cargarResumen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen general', style: theme.textTheme.headlineLarge),
            const SizedBox(height: 4),
            Text(
              DateFormat("EEEE d 'de' MMMM 'de' y", 'es').format(DateTime.now()),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final columnas = constraints.maxWidth > 900 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columnas,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    StatCard(
                      titulo: 'Cultivos activos',
                      valor: '$_cultivosActivos',
                      icono: Icons.grass_rounded,
                      color: AppColors.cultivos,
                    ),
                    StatCard(
                      titulo: 'Animales',
                      valor: '$_cantidadAnimales',
                      icono: Icons.pets_rounded,
                      color: AppColors.ganado,
                    ),
                    StatCard(
                      titulo: 'Ingresos del mes',
                      valor: _currency.format(_ingresosMes),
                      icono: Icons.trending_up_rounded,
                      color: AppColors.success,
                    ),
                    StatCard(
                      titulo: 'Gastos del mes',
                      valor: _currency.format(_gastosMes),
                      icono: Icons.trending_down_rounded,
                      color: AppColors.danger,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: balance >= 0
                    ? AppColors.primaryGreen
                    : AppColors.danger,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Balance actual',
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      Text(
                        _currency.format(balance),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white, size: 40),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Próximas tareas', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _proximasTareas.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.4)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'No tenés tareas próximas cargadas en el calendario.',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        for (var i = 0; i < _proximasTareas.length; i++) ...[
                          if (i > 0) const Divider(height: 1),
                          ListTile(
                            leading: Icon(Icons.event_rounded,
                                color: AppColors.calendario),
                            title: Text(_proximasTareas[i].titulo),
                            subtitle: Text(
                              TiposEvento.etiquetas[_proximasTareas[i].tipo] ??
                                  _proximasTareas[i].tipo,
                            ),
                            trailing: Text(
                              DateFormat('dd/MM/yyyy')
                                  .format(_proximasTareas[i].fecha),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
