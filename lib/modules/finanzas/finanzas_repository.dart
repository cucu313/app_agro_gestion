import '../../core/database/database_helper.dart';
import '../../models/finanza.dart';

class FinanzasRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<MovimientoFinanciero>> obtenerTodos({
    DateTime? desde,
    DateTime? hasta,
    String? tipo,
  }) async {
    final db = await _dbHelper.database;
    final condiciones = <String>[];
    final args = <Object?>[];

    if (desde != null) {
      condiciones.add('fecha >= ?');
      args.add(desde.toIso8601String());
    }
    if (hasta != null) {
      condiciones.add('fecha <= ?');
      args.add(hasta.toIso8601String());
    }
    if (tipo != null) {
      condiciones.add('tipo = ?');
      args.add(tipo);
    }

    final where = condiciones.isEmpty ? null : condiciones.join(' AND ');
    final maps = await db.query(
      'movimientos_financieros',
      where: where,
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha DESC',
    );
    return maps.map((m) => MovimientoFinanciero.fromMap(m)).toList();
  }

  Future<int> crear(MovimientoFinanciero mov) async {
    final db = await _dbHelper.database;
    return db.insert('movimientos_financieros', mov.toMap());
  }

  Future<int> actualizar(MovimientoFinanciero mov) async {
    final db = await _dbHelper.database;
    return db.update('movimientos_financieros', mov.toMap(),
        where: 'id = ?', whereArgs: [mov.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('movimientos_financieros',
        where: 'id = ?', whereArgs: [id]);
  }

  /// Devuelve (totalIngresos, totalEgresos) para un rango de fechas dado.
  Future<(double, double)> totalesPorRango(DateTime desde, DateTime hasta) async {
    final db = await _dbHelper.database;
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
    final totalIngresos = (ingresos.first['total'] as num).toDouble();
    final totalEgresos = (egresos.first['total'] as num).toDouble();
    return (totalIngresos, totalEgresos);
  }
}
