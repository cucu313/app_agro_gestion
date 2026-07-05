/// Evento del calendario agrícola.
class EventoCalendario {
  final int? id;
  final String titulo;
  final String tipo; // vacunacion|siembra|cosecha|fertilizacion|reparacion|recordatorio|vencimiento
  final DateTime fecha;
  final String? notas;
  final bool notificar;
  final bool completado;

  EventoCalendario({
    this.id,
    required this.titulo,
    required this.tipo,
    required this.fecha,
    this.notas,
    this.notificar = true,
    this.completado = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'notas': notas,
      'notificar': notificar ? 1 : 0,
      'completado': completado ? 1 : 0,
    };
  }

  factory EventoCalendario.fromMap(Map<String, dynamic> map) {
    return EventoCalendario(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      tipo: map['tipo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      notas: map['notas'] as String?,
      notificar: (map['notificar'] as int? ?? 1) == 1,
      completado: (map['completado'] as int? ?? 0) == 1,
    );
  }
}

class TiposEvento {
  static const Map<String, String> etiquetas = {
    'vacunacion': 'Vacunación',
    'siembra': 'Siembra',
    'cosecha': 'Cosecha',
    'fertilizacion': 'Fertilización',
    'reparacion': 'Reparación',
    'recordatorio': 'Recordatorio',
    'vencimiento': 'Vencimiento',
  };
}
