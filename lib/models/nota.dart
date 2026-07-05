/// Nota libre para observaciones generales del establecimiento, ideas,
/// pendientes rápidos, etc. No está atada a ningún otro módulo.
class Nota {
  final int? id;
  final String titulo;
  final String contenido;
  final bool fijada;
  final DateTime creadaEn;
  final DateTime actualizadaEn;

  Nota({
    this.id,
    required this.titulo,
    required this.contenido,
    this.fijada = false,
    DateTime? creadaEn,
    DateTime? actualizadaEn,
  })  : creadaEn = creadaEn ?? DateTime.now(),
        actualizadaEn = actualizadaEn ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'contenido': contenido,
      'fijada': fijada ? 1 : 0,
      'creada_en': creadaEn.toIso8601String(),
      'actualizada_en': actualizadaEn.toIso8601String(),
    };
  }

  factory Nota.fromMap(Map<String, dynamic> map) {
    return Nota(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      contenido: map['contenido'] as String,
      fijada: (map['fijada'] as int? ?? 0) == 1,
      creadaEn: DateTime.parse(map['creada_en'] as String),
      actualizadaEn: DateTime.parse(map['actualizada_en'] as String),
    );
  }

  Nota copyWith({
    String? titulo,
    String? contenido,
    bool? fijada,
  }) {
    return Nota(
      id: id,
      titulo: titulo ?? this.titulo,
      contenido: contenido ?? this.contenido,
      fijada: fijada ?? this.fijada,
      creadaEn: creadaEn,
      actualizadaEn: DateTime.now(),
    );
  }
}
