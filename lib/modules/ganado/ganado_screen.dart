import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/animal.dart';
import 'animales_repository.dart';
import 'animal_form_screen.dart';
import 'animal_detail_screen.dart';

class GanadoScreen extends StatefulWidget {
  const GanadoScreen({super.key});

  @override
  State<GanadoScreen> createState() => _GanadoScreenState();
}

class _GanadoScreenState extends State<GanadoScreen> {
  final _repo = AnimalesRepository();
  List<Animal> _animales = [];
  bool _cargando = true;
  bool _soloActivos = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final animales = await _repo.obtenerTodos(soloActivos: _soloActivos);
    if (!mounted) return;
    setState(() {
      _animales = animales;
      _cargando = false;
    });
  }

  Future<void> _abrirFormulario({Animal? animal}) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AnimalFormScreen(animal: animal)),
    );
    if (resultado == true) _cargar();
  }

  Future<void> _abrirDetalle(Animal animal) async {
    final resultado = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AnimalDetailScreen(animal: animal)),
    );
    if (resultado == true) _cargar();
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
              Text('🐄 Ganado', style: theme.textTheme.headlineLarge),
              ElevatedButton.icon(
                onPressed: () => _abrirFormulario(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nuevo animal'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilterChip(
                label: const Text('Solo activos'),
                selected: _soloActivos,
                onSelected: (v) {
                  setState(() => _soloActivos = v);
                  _cargar();
                },
                selectedColor: AppColors.ganado.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : _animales.isEmpty
                    ? _EstadoVacio(onCrear: () => _abrirFormulario())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 320,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: _animales.length,
                        itemBuilder: (context, i) {
                          final animal = _animales[i];
                          return _AnimalCard(
                            animal: animal,
                            onTap: () => _abrirDetalle(animal),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;
  const _AnimalCard({required this.animal, required this.onTap});

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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.ganado.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pets_rounded,
                        color: AppColors.ganado, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.nombre?.isNotEmpty == true
                              ? animal.nombre!
                              : 'Caravana ${animal.caravana}',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text('N° ${animal.caravana}',
                            style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _Info(label: 'Sexo', valor: animal.sexo ?? '—'),
              const SizedBox(height: 6),
              _Info(label: 'Raza', valor: animal.raza ?? '—'),
              const SizedBox(height: 6),
              _Info(
                  label: 'Peso',
                  valor: animal.peso != null ? '${animal.peso} kg' : '—'),
              const SizedBox(height: 6),
              _Info(
                label: 'Nacimiento',
                valor: animal.fechaNacimiento != null
                    ? dateFmt.format(animal.fechaNacimiento!)
                    : '—',
              ),
              const Spacer(),
              if (animal.estadoSanitario != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    animal.estadoSanitario!,
                    style: const TextStyle(
                      color: AppColors.info,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String label;
  final String valor;
  const _Info({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
        Text(valor, style: theme.textTheme.bodySmall),
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
          Icon(Icons.pets_rounded,
              size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('Todavía no hay animales cargados',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Registrá tu primer animal para empezar a llevar su historial.',
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Registrar animal'),
          ),
        ],
      ),
    );
  }
}
