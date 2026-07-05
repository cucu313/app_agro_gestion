/// Representa un lote / parcela de cultivo.
class Lote {
  final int? id;
  final String nombre;
  final String? numero;
  final double? superficie; // en hectáreas
  final String? tipoCultivo;
  final DateTime? fechaSiembra;
  final DateTime? fechaCosechaEstimada;
  final String estado; // Sembrado, En crecimiento, Cosechado, etc.
  final String? observaciones;
  final DateTime creadoEn;

  Lote({
    this.id,
    required this.nombre,
    this.numero,
    this.superficie,
    this.tipoCultivo,
    this.fechaSiembra,
    this.fechaCosechaEstimada,
    this.estado = 'Sembrado',
    this.observaciones,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'numero': numero,
      'superficie': superficie,
      'tipo_cultivo': tipoCultivo,
      'fecha_siembra': fechaSiembra?.toIso8601String(),
      'fecha_cosecha_estimada': fechaCosechaEstimada?.toIso8601String(),
      'estado': estado,
      'observaciones': observaciones,
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  factory Lote.fromMap(Map<String, dynamic> map) {
    return Lote(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      numero: map['numero'] as String?,
      superficie: (map['superficie'] as num?)?.toDouble(),
      tipoCultivo: map['tipo_cultivo'] as String?,
      fechaSiembra: map['fecha_siembra'] != null
          ? DateTime.parse(map['fecha_siembra'] as String)
          : null,
      fechaCosechaEstimada: map['fecha_cosecha_estimada'] != null
          ? DateTime.parse(map['fecha_cosecha_estimada'] as String)
          : null,
      estado: map['estado'] as String? ?? 'Sembrado',
      observaciones: map['observaciones'] as String?,
      creadoEn: DateTime.parse(map['creado_en'] as String),
    );
  }

  Lote copyWith({
    int? id,
    String? nombre,
    String? numero,
    double? superficie,
    String? tipoCultivo,
    DateTime? fechaSiembra,
    DateTime? fechaCosechaEstimada,
    String? estado,
    String? observaciones,
  }) {
    return Lote(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      numero: numero ?? this.numero,
      superficie: superficie ?? this.superficie,
      tipoCultivo: tipoCultivo ?? this.tipoCultivo,
      fechaSiembra: fechaSiembra ?? this.fechaSiembra,
      fechaCosechaEstimada:
          fechaCosechaEstimada ?? this.fechaCosechaEstimada,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      creadoEn: creadoEn,
    );
  }
}

/// Registro de labor sobre un lote: fertilización, aplicación, riego o
/// producción obtenida. El campo [tipo] distingue cada caso.
class LoteLabor {
  final int? id;
  final int loteId;
  final String tipo; // fertilizacion | aplicacion | riego | produccion
  final DateTime fecha;
  final String? producto;
  final String? dosis;
  final double? cantidad;
  final String? unidad;
  final String? observaciones;

  LoteLabor({
    this.id,
    required this.loteId,
    required this.tipo,
    required this.fecha,
    this.producto,
    this.dosis,
    this.cantidad,
    this.unidad,
    this.observaciones,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'lote_id': loteId,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'producto': producto,
      'dosis': dosis,
      'cantidad': cantidad,
      'unidad': unidad,
      'observaciones': observaciones,
    };
  }

  factory LoteLabor.fromMap(Map<String, dynamic> map) {
    return LoteLabor(
      id: map['id'] as int?,
      loteId: map['lote_id'] as int,
      tipo: map['tipo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      producto: map['producto'] as String?,
      dosis: map['dosis'] as String?,
      cantidad: (map['cantidad'] as num?)?.toDouble(),
      unidad: map['unidad'] as String?,
      observaciones: map['observaciones'] as String?,
    );
  }
}
