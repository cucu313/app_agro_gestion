/// Representa un animal del rodeo/majada.
class Animal {
  final int? id;
  final String caravana;
  final String? nombre;
  final String? sexo; // Macho | Hembra
  final String? raza;
  final DateTime? fechaNacimiento;
  final double? peso;
  final String? estadoSanitario;
  final bool activo;
  final DateTime creadoEn;

  Animal({
    this.id,
    required this.caravana,
    this.nombre,
    this.sexo,
    this.raza,
    this.fechaNacimiento,
    this.peso,
    this.estadoSanitario,
    this.activo = true,
    DateTime? creadoEn,
  }) : creadoEn = creadoEn ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caravana': caravana,
      'nombre': nombre,
      'sexo': sexo,
      'raza': raza,
      'fecha_nacimiento': fechaNacimiento?.toIso8601String(),
      'peso': peso,
      'estado_sanitario': estadoSanitario,
      'activo': activo ? 1 : 0,
      'creado_en': creadoEn.toIso8601String(),
    };
  }

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      id: map['id'] as int?,
      caravana: map['caravana'] as String,
      nombre: map['nombre'] as String?,
      sexo: map['sexo'] as String?,
      raza: map['raza'] as String?,
      fechaNacimiento: map['fecha_nacimiento'] != null
          ? DateTime.parse(map['fecha_nacimiento'] as String)
          : null,
      peso: (map['peso'] as num?)?.toDouble(),
      estadoSanitario: map['estado_sanitario'] as String?,
      activo: (map['activo'] as int? ?? 1) == 1,
      creadoEn: DateTime.parse(map['creado_en'] as String),
    );
  }
}

/// Evento del historial de un animal: vacuna, tratamiento, reproducción,
/// compra, venta, fallecimiento u observación.
class AnimalEvento {
  final int? id;
  final int animalId;
  final String tipo;
  final DateTime fecha;
  final String? detalle;
  final double? monto;

  AnimalEvento({
    this.id,
    required this.animalId,
    required this.tipo,
    required this.fecha,
    this.detalle,
    this.monto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'animal_id': animalId,
      'tipo': tipo,
      'fecha': fecha.toIso8601String(),
      'detalle': detalle,
      'monto': monto,
    };
  }

  factory AnimalEvento.fromMap(Map<String, dynamic> map) {
    return AnimalEvento(
      id: map['id'] as int?,
      animalId: map['animal_id'] as int,
      tipo: map['tipo'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      detalle: map['detalle'] as String?,
      monto: (map['monto'] as num?)?.toDouble(),
    );
  }
}
