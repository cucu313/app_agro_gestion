import 'package:flutter/material.dart';

/// Pantalla base reutilizable para módulos aún no desarrollados en
/// profundidad. Sirve como punto de partida: seguir el mismo patrón de
/// carpetas usado en el módulo Cultivos (repository + models + list +
/// form + detail) para completarlos.
class ModulePlaceholder extends StatelessWidget {
  final String emoji;
  final String titulo;
  final Color color;
  final String descripcion;

  const ModulePlaceholder({
    super.key,
    required this.emoji,
    required this.titulo,
    required this.color,
    required this.descripcion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$emoji $titulo', style: theme.textTheme.headlineLarge),
          const SizedBox(height: 24),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Módulo $titulo — próximo a completar',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      descripcion,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
