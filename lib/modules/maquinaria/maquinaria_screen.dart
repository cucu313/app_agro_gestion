import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/maquinaria.dart';
import 'maquinaria_repository.dart';
import 'maquinaria_form_screen.dart';
import 'maquinaria_detail_screen.dart';

class MaquinariaScreen extends StatefulWidget {
  const MaquinariaScreen({super.key});

  @override
  State<MaquinariaScreen> createState() => _MaquinariaScreenState();
}

class _MaquinariaScreenState extends State<MaquinariaScreen> {
  final _repo = MaquinariaRepository();
  List<Maquinaria> _maquinas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final maquinas = await _repo.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _maquinas = maquinas;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario({Maquinaria? maquinaria}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => MaquinariaFormScreen(maquinaria: maquinaria)),
    );
    if (resultado == true) _cargar();
  }

  Future<void> _abrirDetalle(Maquinaria maquinaria) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => MaquinariaDetailScreen(maquinaria: maquinaria)),
    );
    if (resultado == true) _cargar();
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'En reparación':
        return AppColors.warning;
      case 'Fuera de servicio':
        return AppColors.danger;
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('🚜 Maquinaria', style: theme.textTheme.headlineLarge),
              ElevatedButton.icon(
                onPressed: () => _abrirFormulario(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nueva máquina'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _maquinas.isEmpty
                    ? _EstadoVacio(onCrear: () => _abrirFormulario())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.3,
                        ),
                        itemCount: _maquinas.length,
                        itemBuilder: (context, i) {
                          final m = _maquinas[i];
                          return _MaquinariaCard(
                            maquinaria: m,
                            colorEstado: _colorEstado(m.estado),
                            onTap: () => _abrirDetalle(m),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _MaquinariaCard extends StatelessWidget {
  final Maquinaria maquinaria;
  final Color colorEstado;
  final VoidCallback onTap;

  const _MaquinariaCard({
    required this.maquinaria,
    required this.colorEstado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                    child: Text(maquinaria.nombre,
                        style: theme.textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorEstado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      maquinaria.estado,
                      style: TextStyle(
                          color: colorEstado,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                  [maquinaria.marca, maquinaria.modelo]
                      .where((e) => e != null && e.isNotEmpty)
                      .join(' · '),
                  style: theme.textTheme.bodySmall),
              const Spacer(),
              _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  text: maquinaria.anio != null ? 'Año ${maquinaria.anio}' : '—'),
              const SizedBox(height: 6),
              _InfoRow(
                  icon: Icons.speed_rounded,
                  text: '${maquinaria.horasUso.toStringAsFixed(0)} hs de uso'),
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
                style: theme.textTheme.bodySmall, overflow: TextOverflow.ellipsis)),
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
          Icon(Icons.agriculture_rounded,
              size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('Todavía no hay maquinaria cargada',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Registrá tu primera máquina para llevar el control de mantenimientos.',
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar máquina'),
          ),
        ],
      ),
    );
  }
}
