import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/lote.dart';
import 'lotes_repository.dart';
import 'cultivo_form_screen.dart';
import 'cultivo_detail_screen.dart';

class CultivosListScreen extends StatefulWidget {
  const CultivosListScreen({super.key});

  @override
  State<CultivosListScreen> createState() => _CultivosListScreenState();
}

class _CultivosListScreenState extends State<CultivosListScreen> {
  final _repo = LotesRepository();
  List<Lote> _lotes = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final lotes = await _repo.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _lotes = lotes;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario({Lote? lote}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CultivoFormScreen(lote: lote)),
    );
    if (resultado == true) _cargar();
  }

  Future<void> _abrirDetalle(Lote lote) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => CultivoDetailScreen(lote: lote)),
    );
    if (resultado == true) _cargar();
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Cosechado':
        return AppColors.wheatGold;
      case 'En crecimiento':
        return AppColors.primaryGreen;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('🌾 Cultivos', style: theme.textTheme.headlineLarge),
                ElevatedButton.icon(
                  onPressed: () => _abrirFormulario(),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Nuevo lote'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _lotes.isEmpty
                      ? _EstadoVacio(onCrear: () => _abrirFormulario())
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 340,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 16,
                            childAspectRatio: 1.25,
                          ),
                          itemCount: _lotes.length,
                          itemBuilder: (context, i) {
                            final lote = _lotes[i];
                            return _LoteCard(
                              lote: lote,
                              colorEstado: _colorEstado(lote.estado),
                              onTap: () => _abrirDetalle(lote),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoteCard extends StatelessWidget {
  final Lote lote;
  final Color colorEstado;
  final VoidCallback onTap;

  const _LoteCard({
    required this.lote,
    required this.colorEstado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy');

    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lote.nombre,
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      lote.estado,
                      style: TextStyle(
                        color: colorEstado,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (lote.numero != null)
                Text('Lote N° ${lote.numero}', style: theme.textTheme.bodySmall),
              const Spacer(),
              _InfoRow(icon: Icons.eco_rounded, text: lote.tipoCultivo ?? '—'),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.straighten_rounded,
                text: lote.superficie != null
                    ? '${lote.superficie} ha'
                    : 'Superficie no definida',
              ),
              const SizedBox(height: 6),
              _InfoRow(
                icon: Icons.event_rounded,
                text: lote.fechaCosechaEstimada != null
                    ? 'Cosecha est.: ${dateFmt.format(lote.fechaCosechaEstimada!)}'
                    : 'Sin fecha de cosecha',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final VoidCallback onCrear;
  const _EstadoVacio({required this.onCrear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.grass_rounded,
              size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('Todavía no hay lotes cargados', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Creá tu primer lote para empezar a llevar el control de tus cultivos.',
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear lote'),
          ),
        ],
      ),
    );
  }
}
