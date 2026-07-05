import '../../core/database/database_helper.dart';

/// Consultas agregadas usadas por el módulo Reportes.
/// Cada método devuelve datos ya resumidos, listos para graficar.
class ReportesRepository {
  final _dbHelper = DatabaseHelper.instance;

  /// Total de egresos agrupados por categoría.
  Future<Map<String, double>> egresosPorCategoria() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(categoria, 'Sin categoría') as categoria, SUM(monto) as total
      FROM movimientos_financieros
      WHERE tipo = 'egreso'
      GROUP BY categoria
      ORDER BY total DESC
    ''');
    return {
      for (final r in rows) r['categoria'] as String: (r['total'] as num).toDouble()
    };
  }

  /// Total de ingresos agrupados por categoría.
  Future<Map<String, double>> ingresosPorCategoria() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(categoria, 'Sin categoría') as categoria, SUM(monto) as total
      FROM movimientos_financieros
      WHERE tipo = 'ingreso'
      GROUP BY categoria
      ORDER BY total DESC
    ''');
    return {
      for (final r in rows) r['categoria'] as String: (r['total'] as num).toDouble()
    };
  }

  /// Ingresos y egresos totales por mes del año indicado (para rentabilidad).
  Future<Map<int, (double, double)>> rentabilidadPorMes(int anio) async {
    final db = await _dbHelper.database;
    final resultado = <int, (double, double)>{};
    for (var mes = 1; mes <= 12; mes++) {
      final desde = DateTime(anio, mes, 1);
      final hasta = DateTime(anio, mes + 1, 0, 23, 59, 59);
      final ingresos = await db.rawQuery(
        '''SELECT COALESCE(SUM(monto),0) as total FROM movimientos_financieros
           WHERE tipo = 'ingreso' AND fecha >= ? AND fecha <= ?''',
        [desde.toIso8601String(), hasta.toIso8601String()],
      );
      final egresos = await db.rawQuery(
        '''SELECT COALESCE(SUM(monto),0) as total FROM movimientos_financieros
           WHERE tipo = 'egreso' AND fecha >= ? AND fecha <= ?''',
        [desde.toIso8601String(), hasta.toIso8601String()],
      );
      resultado[mes] = (
        (ingresos.first['total'] as num).toDouble(),
        (egresos.first['total'] as num).toDouble(),
      );
    }
    return resultado;
  }

  /// Producción total registrada por lote (suma de labores tipo 'produccion').
  Future<Map<String, double>> produccionPorCultivo() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT l.nombre as nombre, COALESCE(SUM(ll.cantidad), 0) as total
      FROM lotes l
      LEFT JOIN lote_labores ll ON ll.lote_id = l.id AND ll.tipo = 'produccion'
      GROUP BY l.id
      ORDER BY total DESC
    ''');
    return {
      for (final r in rows) r['nombre'] as String: (r['total'] as num).toDouble()
    };
  }

  /// Cantidad de animales activos agrupados por raza (evolución del ganado).
  Future<Map<String, int>> animalesPorRaza() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT COALESCE(raza, 'Sin especificar') as raza, COUNT(*) as total
      FROM animales
      WHERE activo = 1
      GROUP BY raza
      ORDER BY total DESC
    ''');
    return {
      for (final r in rows) r['raza'] as String: (r['total'] as int)
    };
  }

  /// Costo total de mantenimiento por máquina.
  Future<Map<String, double>> costoMantenimientoPorMaquina() async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT m.nombre as nombre, COALESCE(SUM(mm.costo), 0) as total
      FROM maquinarias m
      LEFT JOIN maquinaria_mantenimientos mm ON mm.maquinaria_id = m.id
      GROUP BY m.id
      ORDER BY total DESC
    ''');
    return {
      for (final r in rows) r['nombre'] as String: (r['total'] as num).toDouble()
    };
  }
}
