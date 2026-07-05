import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../models/nota.dart';
import 'notas_repository.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen> {
  final _repo = NotasRepository();
  List<Nota> _notas = [];
  bool _cargando = true;
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final notas = await _repo.obtenerTodas();
    if (!mounted) return;
    setState(() {
      _notas = notas;
      _cargando = false;
    });
  }

  List<Nota> get _notasFiltradas {
    if (_busqueda.trim().isEmpty) return _notas;
    final q = _busqueda.toLowerCase();
    return _notas
        .where((n) =>
            n.titulo.toLowerCase().contains(q) ||
            n.contenido.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _abrirEditor({Nota? nota}) async {
    final resultado = await showDialog<Nota>(
      context: context,
      builder: (_) => _NotaDialog(nota: nota),
    );
    if (resultado == null) return;

    if (nota != null) {
      await _repo.actualizar(resultado);
    } else {
      await _repo.crear(resultado);
    }
    _cargar();
  }

  Future<void> _eliminar(Nota nota) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: Text('¿Eliminar "${nota.titulo}"?'),
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
      await _repo.eliminar(nota.id!);
      _cargar();
    }
  }

  Future<void> _alternarFijada(Nota nota) async {
    await _repo.alternarFijada(nota.id!, !nota.fijada);
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notas = _notasFiltradas;

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📝 Notas', style: theme.textTheme.headlineLarge),
              ElevatedButton.icon(
                onPressed: () => _abrirEditor(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nueva nota'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Buscar en notas...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _busqueda = v),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : notas.isEmpty
                    ? _EstadoVacio(onCrear: () => _abrirEditor())
                    : MasonryLikeGrid(
                        notas: notas,
                        onTap: (n) => _abrirEditor(nota: n),
                        onEliminar: _eliminar,
                        onFijar: _alternarFijada,
                      ),
          ),
        ],
      ),
    );
  }
}

/// Grilla simple de tarjetas de notas (tipo "corcho" de notas adhesivas).
class MasonryLikeGrid extends StatelessWidget {
  final List<Nota> notas;
  final ValueChanged<Nota> onTap;
  final ValueChanged<Nota> onEliminar;
  final ValueChanged<Nota> onFijar;

  const MasonryLikeGrid({
    super.key,
    required this.notas,
    required this.onTap,
    required this.onEliminar,
    required this.onFijar,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: notas.length,
      itemBuilder: (context, i) {
        final nota = notas[i];
        return _NotaCard(
          nota: nota,
          onTap: () => onTap(nota),
          onEliminar: () => onEliminar(nota),
          onFijar: () => onFijar(nota),
        );
      },
    );
  }
}

class _NotaCard extends StatelessWidget {
  final Nota nota;
  final VoidCallback onTap;
  final VoidCallback onEliminar;
  final VoidCallback onFijar;

  const _NotaCard({
    required this.nota,
    required this.onTap,
    required this.onEliminar,
    required this.onFijar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    return Material(
      color: nota.fijada
          ? AppColors.wheatGold.withValues(alpha: 0.12)
          : theme.cardTheme.color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nota.titulo,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onFijar,
                    child: Icon(
                      nota.fijada ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 18,
                      color: nota.fijada
                          ? AppColors.wheatGold
                          : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(
                  nota.contenido,
                  style: theme.textTheme.bodyMedium,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFmt.format(nota.actualizadaEn),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                  InkWell(
                    onTap: onEliminar,
                    child: Icon(Icons.delete_outline_rounded,
                        size: 18,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
          Icon(Icons.notes_rounded,
              size: 56, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text('Todavía no hay notas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Usá las notas para ideas, pendientes o recordatorios sueltos.',
              style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onCrear,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear nota'),
          ),
        ],
      ),
    );
  }
}

class _NotaDialog extends StatefulWidget {
  final Nota? nota;
  const _NotaDialog({this.nota});

  @override
  State<_NotaDialog> createState() => _NotaDialogState();
}

class _NotaDialogState extends State<_NotaDialog> {
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _contenidoCtrl;
  late bool _fijada;

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.nota?.titulo ?? '');
    _contenidoCtrl = TextEditingController(text: widget.nota?.contenido ?? '');
    _fijada = widget.nota?.fijada ?? false;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _contenidoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.nota != null ? 'Editar nota' : 'Nueva nota'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tituloCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _contenidoCtrl,
                decoration: const InputDecoration(labelText: 'Contenido'),
                maxLines: 6,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fijar nota'),
                value: _fijada,
                onChanged: (v) => setState(() => _fijada = v),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_tituloCtrl.text.trim().isEmpty) return;
            final nota = widget.nota != null
                ? widget.nota!.copyWith(
                    titulo: _tituloCtrl.text.trim(),
                    contenido: _contenidoCtrl.text.trim(),
                    fijada: _fijada,
                  )
                : Nota(
                    titulo: _tituloCtrl.text.trim(),
                    contenido: _contenidoCtrl.text.trim(),
                    fijada: _fijada,
                  );
            Navigator.pop(context, nota);
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
