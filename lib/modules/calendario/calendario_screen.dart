import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/notifications/notification_service.dart';
import '../../models/evento_calendario.dart';
import 'calendario_repository.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  final _repo = CalendarioRepository();
  List<EventoCalendario> _eventos = [];
  bool _cargando = true;

  DateTime _mesEnfocado = DateTime.now();
  DateTime _diaSeleccionado = DateTime.now();

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    final eventos = await _repo.obtenerTodos();
    if (!mounted) return;
    setState(() {
      _eventos = eventos;
      _cargando = false;
    });
  }

  List<EventoCalendario> _eventosDelDia(DateTime dia) {
    return _eventos
        .where((e) =>
            e.fecha.year == dia.year &&
            e.fecha.month == dia.month &&
            e.fecha.day == dia.day)
        .toList();
  }

  Future<void> _agregarEvento() async {
    final resultado = await showDialog<EventoCalendario>(
      context: context,
      builder: (_) => _EventoDialog(fechaInicial: _diaSeleccionado),
    );
    if (resultado != null) {
      final id = await _repo.crear(resultado);
      if (resultado.notificar) {
        await NotificationService.instance.programarNotificacion(
          id: id,
          titulo: resultado.titulo,
          cuerpo: TiposEvento.etiquetas[resultado.tipo] ?? resultado.tipo,
          fecha: resultado.fecha,
        );
      }
      _cargar();
    }
  }

  Future<void> _alternarCompletado(EventoCalendario evento) async {
    await _repo.marcarCompletado(evento.id!, !evento.completado);
    if (!evento.completado) {
      await NotificationService.instance.cancelarNotificacion(evento.id!);
    }
    _cargar();
  }

  Future<void> _eliminarEvento(EventoCalendario evento) async {
    await _repo.eliminar(evento.id!);
    await NotificationService.instance.cancelarNotificacion(evento.id!);
    _cargar();
  }

  Color _colorTipo(String tipo) {
    switch (tipo) {
      case 'vacunacion':
        return AppColors.ganado;
      case 'siembra':
      case 'cosecha':
      case 'fertilizacion':
        return AppColors.cultivos;
      case 'reparacion':
        return AppColors.maquinaria;
      case 'vencimiento':
        return AppColors.danger;
      default:
        return AppColors.calendario;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventosDelDia = _eventosDelDia(_diaSeleccionado);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('📅 Calendario', style: theme.textTheme.headlineLarge),
              ElevatedButton.icon(
                onPressed: _agregarEvento,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Nuevo evento'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TableCalendar<EventoCalendario>(
                            locale: 'es_AR',
                            firstDay: DateTime(2020, 1, 1),
                            lastDay: DateTime(2100, 12, 31),
                            focusedDay: _mesEnfocado,
                            selectedDayPredicate: (day) =>
                                isSameDay(day, _diaSeleccionado),
                            eventLoader: _eventosDelDia,
                            onDaySelected: (dia, mesEnfocado) {
                              setState(() {
                                _diaSeleccionado = dia;
                                _mesEnfocado = mesEnfocado;
                              });
                            },
                            onPageChanged: (mesEnfocado) {
                              _mesEnfocado = mesEnfocado;
                            },
                            calendarFormat: CalendarFormat.month,
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                            ),
                            calendarStyle: CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              selectedDecoration: const BoxDecoration(
                                color: AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              markerDecoration: const BoxDecoration(
                                color: AppColors.wheatGold,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: theme.cardTheme.color,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat("EEEE d 'de' MMMM", 'es_AR')
                                    .format(_diaSeleccionado),
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: eventosDelDia.isEmpty
                                    ? Center(
                                        child: Text('Sin eventos este día',
                                            style: theme.textTheme.bodyMedium))
                                    : ListView.separated(
                                        itemCount: eventosDelDia.length,
                                        separatorBuilder: (_, __) =>
                                            const Divider(height: 1),
                                        itemBuilder: (context, i) {
                                          final e = eventosDelDia[i];
                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: _colorTipo(e.tipo),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            title: Text(
                                              e.titulo,
                                              style: TextStyle(
                                                decoration: e.completado
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                            subtitle: Text(
                                                TiposEvento.etiquetas[e.tipo] ?? e.tipo),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    e.completado
                                                        ? Icons.check_circle_rounded
                                                        : Icons
                                                            .radio_button_unchecked_rounded,
                                                    size: 20,
                                                    color: e.completado
                                                        ? AppColors.success
                                                        : null,
                                                  ),
                                                  onPressed: () =>
                                                      _alternarCompletado(e),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                      Icons.delete_outline_rounded,
                                                      size: 20),
                                                  onPressed: () =>
                                                      _eliminarEvento(e),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _EventoDialog extends StatefulWidget {
  final DateTime fechaInicial;
  const _EventoDialog({required this.fechaInicial});

  @override
  State<_EventoDialog> createState() => _EventoDialogState();
}

class _EventoDialogState extends State<_EventoDialog> {
  final _tituloCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  final _dateFmt = DateFormat('dd/MM/yyyy');
  String _tipo = 'recordatorio';
  late DateTime _fecha;
  bool _notificar = true;

  @override
  void initState() {
    super.initState();
    _fecha = widget.fechaInicial;
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (fecha != null) setState(() => _fecha = fecha);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo evento'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _tipo,
              decoration: const InputDecoration(labelText: 'Tipo de evento'),
              items: TiposEvento.etiquetas.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _tipo = v ?? _tipo),
            ),
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _seleccionarFecha,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Fecha'),
                child: Text(_dateFmt.format(_fecha)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notasCtrl,
              decoration: const InputDecoration(labelText: 'Notas'),
              maxLines: 2,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Notificarme'),
              value: _notificar,
              onChanged: (v) => setState(() => _notificar = v),
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
            if (_tituloCtrl.text.trim().isEmpty) return;
            Navigator.pop(
              context,
              EventoCalendario(
                titulo: _tituloCtrl.text.trim(),
                tipo: _tipo,
                fecha: _fecha,
                notas: _notasCtrl.text.trim().isEmpty
                    ? null
                    : _notasCtrl.text.trim(),
                notificar: _notificar,
              ),
            );
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
