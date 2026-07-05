/// Representa una máquina o implemento agrícola.
class Maquinaria {
  final int? id;
  final String nombre;
  final String? marca;
  final String? modelo;
  final int? anio;
  final double horasUso;
  final String estado; // Operativo | En reparación | Fuera de servicio
  final DateTime creadoEn;

  Maquinaria({
    this.id,
    required this.nombre,
    this.marca,
    this.modelo,
    this.anio,
    this.horasUso = 0,
    this.estado = 'Operativo',
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'horas_uso': horasUso,
      'estado': estado,
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  factory Maquinaria.fromMap(Map<String, dynamic> map) {
    return Maquinaria(
      id: map['id'] as int?,
      nombre: map['nombre'] as String,
      marca: map['marca'] as String?,
      modelo: map['modelo'] as String?,
      anio: map['anio'] as int?,
      horasUso: (map['horas_uso'] as num?)?.toDouble() ?? 0,
      estado: map['estado'] as String? ?? 'Operativo',
      creadoEn: DateTime.parse(map['creado_en'] as String),
    );
  }
}

/// Mantenimiento, cambio de aceite, reparación o carga de combustible.
class MaquinariaMantenimiento {
  final int? id;
  final int maquinariaId;
  final String tipo; // mantenimiento | cambio_aceite | reparacion | combustible
  final DateTime fecha;
  final String? descripcion;
  final double? costo;
  final DateTime? proximoServicio;

  MaquinariaMantenimiento({
    this.id,
    required this.maquinariaId,
    required this.tipo,
    required this.fecha,
    this.descripcion,
    this.costo,
    this.proximoServicio,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maquinaria_id': maquinariaId,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'descripcion': descripcion,
      'costo': costo,
      'proximo_servicio': proximoServicio?.toIso8601String(),
    };
  }

  factory MaquinariaMantenimiento.fromMap(Map<String, dynamic> map) {
    return MaquinariaMantenimiento(
      id: map['id'] as int?,
      maquinariaId: map['maquinaria_id'] as int,
      tipo: map['tipo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      descripcion: map['descripcion'] as String?,
      costo: (map['costo'] as num?)?.toDouble(),
      proximoServicio: map['proximo_servicio'] != null
          ? DateTime.parse(map['proximo_servicio'] as String)
          : null,
    );
  }
}
