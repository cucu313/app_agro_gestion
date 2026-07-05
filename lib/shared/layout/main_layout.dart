import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../modules/dashboard/dashboard_screen.dart';
import '../../modules/cultivos/cultivos_list_screen.dart';
import '../../modules/ganado/ganado_screen.dart';
import '../../modules/maquinaria/maquinaria_screen.dart';
import '../../modules/finanzas/finanzas_screen.dart';
import '../../modules/calendario/calendario_screen.dart';
import '../../modules/reportes/reportes_screen.dart';
import '../../modules/configuracion/configuracion_screen.dart';
import '../../modules/notas/notas_screen.dart';

class _SeccionMenu {
  final String titulo;
  final IconData icono;
  final Widget pantalla;
  const _SeccionMenu(this.titulo, this.icono, this.pantalla);
}

/// Estructura general de la app para iPad: menú lateral permanente a la
/// izquierda y contenido a la derecha. Pensado para orientación horizontal.
class MainLayout extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainLayout({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _seleccionado = 0;

  late final List<_SeccionMenu> _secciones = [
    _SeccionMenu('Inicio', Icons.home_rounded, const DashboardScreen()),
    _SeccionMenu('Cultivos', Icons.grass_rounded, const CultivosListScreen()),
    _SeccionMenu('Ganado', Icons.pets_rounded, const GanadoScreen()),
    _SeccionMenu(
        'Maquinaria', Icons.agriculture_rounded, const MaquinariaScreen()),
    _SeccionMenu(
        'Finanzas', Icons.attach_money_rounded, const FinanzasScreen()),
    _SeccionMenu(
        'Calendario', Icons.calendar_month_rounded, const CalendarioScreen()),
    _SeccionMenu('Reportes', Icons.bar_chart_rounded, const ReportesScreen()),
    _SeccionMenu('Notas', Icons.notes_rounded, const NotasScreen()),
    _SeccionMenu('Configuración', Icons.settings_rounded,
        const ConfiguracionScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          _SidebarMenu(
            secciones: _secciones,
            seleccionado: _seleccionado,
            onSeleccionar: (i) => setState(() => _seleccionado = i),
            isDarkMode: widget.isDarkMode,
            onToggleTheme: widget.onToggleTheme,
          ),
          Expanded(
            child: Container(
              color: colorScheme.surface == AppColors.white
                  ? AppColors.offWhite
                  : null,
              child: _secciones[_seleccionado].pantalla,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarMenu extends StatelessWidget {
  final List<_SeccionMenu> secciones;
  final int seleccionado;
  final ValueChanged<int> onSeleccionar;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const _SidebarMenu({
    required this.secciones,
    required this.seleccionado,
    required this.onSeleccionar,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          right: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'AgroApp',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: secciones.length,
                itemBuilder: (context, index) {
                  final activo = index == seleccionado;
                  final seccion = secciones[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: activo
                          ? AppColors.primaryGreen.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSeleccionar(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                seccion.icono,
                                size: 20,
                                color: activo
                                    ? AppColors.primaryGreen
                                    : theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                seccion.titulo,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: activo
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: activo
                                      ? AppColors.primaryGreen
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    size: 20,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Modo oscuro', style: theme.textTheme.bodyMedium),
                  ),
                  Switch.adaptive(
                    value: isDarkMode,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (_) => onToggleTheme(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
