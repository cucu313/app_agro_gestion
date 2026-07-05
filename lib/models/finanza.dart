/// Movimiento financiero (ingreso o egreso).
class MovimientoFinanciero {
  final int? id;
  final String tipo; // ingreso | egreso
  final DateTime fecha;
  final String concepto;
  final String? categoria;
  final double monto;
  final String? observaciones;
  final DateTime creadoEn;

  MovimientoFinanciero({
    this.id,
    required this.tipo,
    required this.fecha,
    required this.concepto,
    this.categoria,
    required this.monto,
    this.observaciones,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'concepto': concepto,
      'categoria': categoria,
      'monto': monto,
      'observaciones': observaciones,
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  factory MovimientoFinanciero.fromMap(Map<String, dynamic> map) {
    return MovimientoFinanciero(
      id: map['id'] as int?,
      tipo: map['tipo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      concepto: map['concepto'] as String,
      categoria: map['categoria'] as String?,
      monto: (map['monto'] as num).toDouble(),
      observaciones: map['observaciones'] as String?,
      creadoEn: DateTime.parse(map['creado_en'] as String),
    );
  }
}

/// Categorías de ingresos y egresos comunes en una explotación agropecuaria.
/// Sirven como sugerencia inicial en los formularios; el usuario puede
/// escribir categorías propias.
class CategoriasFinanzas {
  static const List<String> ingresos = [
    'Venta de cultivo',
    'Venta de ganado',
    'Subsidios',
    'Alquileres',
    'Otros ingresos',
  ];

  static const List<String> egresos = [
    'Insumos',
    'Combustible',
    'Mantenimiento',
    'Sanidad animal',
    'Mano de obra',
    'Impuestos',
    'Otros egresos',
  ];
}
