import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';

/// Configuración general: datos del establecimiento, moneda, tema,
/// copias de seguridad y exportación/importación de la base de datos.
class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  final _nombreEstablecimientoCtrl = TextEditingController();
  final _nombreProductorCtrl = TextEditingController();
  String _moneda = 'ARS';

  final _monedas = const ['ARS', 'USD', 'EUR', 'BRL', 'UYU'];

  @override
  void initState() {
    super.initState();
    _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    final db = await DatabaseHelper.instance.database;
    final rows = await db.query('configuracion');
    final valores = {for (final r in rows) r['clave']: r['valor']};
    if (!mounted) return;
    setState(() {
      _nombreEstablecimientoCtrl.text =
          (valores['nombre_establecimiento'] as String?) ?? '';
      _nombreProductorCtrl.text =
          (valores['nombre_productor'] as String?) ?? '';
      _moneda = (valores['moneda'] as String?) ?? 'ARS';
    });
  }

  Future<void> _guardarClave(String clave, String valor) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert(
      'configuracion',
      {'clave': clave, 'valor': valor},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚙ Configuración', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Datos del establecimiento', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreEstablecimientoCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Nombre del establecimiento'),
                    onSubmitted: (v) => _guardarClave('nombre_establecimiento', v),
                    onTapOutside: (_) => _guardarClave(
                        'nombre_establecimiento', _nombreEstablecimientoCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombreProductorCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre del productor'),
                    onSubmitted: (v) => _guardarClave('nombre_productor', v),
                    onTapOutside: (_) => _guardarClave(
                        'nombre_productor', _nombreProductorCtrl.text),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _moneda,
                    decoration: const InputDecoration(labelText: 'Moneda'),
                    items: _monedas
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _moneda = v);
                      _guardarClave('moneda', v);
                    },
                  ),
                  const SizedBox(height: 28),
                  Text('Datos y copias de seguridad', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  _AccionCard(
                    icono: Icons.download_rounded,
                    titulo: 'Exportar base de datos',
                    subtitulo: 'Genera una copia del archivo .db para guardarla donde quieras.',
                    onTap: () => _mostrarProximamente(context),
                  ),
                  const SizedBox(height: 10),
                  _AccionCard(
                    icono: Icons.upload_rounded,
                    titulo: 'Importar / restaurar base de datos',
                    subtitulo: 'Reemplaza los datos actuales por los de un archivo de copia.',
                    onTap: () => _mostrarProximamente(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarProximamente(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Función lista para implementar con file_picker + copia del archivo .db (ver README).'),
      ),
    );
  }
}

class _AccionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;

  const _AccionCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardTheme.color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icono, color: theme.colorScheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titulo, style: theme.textTheme.titleMedium),
                    Text(subtitulo, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
