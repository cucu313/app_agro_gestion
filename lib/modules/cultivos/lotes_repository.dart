import '../../core/database/database_helper.dart';
import '../../models/lote.dart';

/// Capa de acceso a datos para el módulo Cultivos.
/// Mantiene toda la lógica SQL fuera de la UI.
class LotesRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Lote>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('lotes', orderBy: 'nombre ASC');
    return maps.map((m) => Lote.fromMap(m)).toList();
  }

  Future<Lote?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('lotes', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Lote.fromMap(maps.first);
  }

  Future<int> crear(Lote lote) async {
    final db = await _dbHelper.database;
    return db.insert('lotes', lote.toMap());
  }

  Future<int> actualizar(Lote lote) async {
    final db = await _dbHelper.database;
    return db.update('lotes', lote.toMap(),
        where: 'id = ?', whereArgs: [lote.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('lotes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarActivos() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      "SELECT COUNT(*) as total FROM lotes WHERE estado != 'Cosechado'",
    );
    return (result.first['total'] as int?) ?? 0;
  }

  // ---- Labores (fertilización, aplicación, riego, producción) ----

  Future<List<LoteLabor>> obtenerLabores(int loteId, {String? tipo}) async {
    final db = await _dbHelper.database;
    final where = tipo != null ? 'lote_id = ? AND tipo = ?' : 'lote_id = ?';
    final args = tipo != null ? [loteId, tipo] : [loteId];
    final maps = await db.query('lote_labores',
        where: where, whereArgs: args, orderBy: 'fecha DESC');
    return maps.map((m) => LoteLabor.fromMap(m)).toList();
  }

  Future<int> crearLabor(LoteLabor labor) async {
    final db = await _dbHelper.database;
    return db.insert('lote_labores', labor.toMap());
  }

  Future<int> eliminarLabor(int id) async {
    final db = await _dbHelper.database;
    return db.delete('lote_labores', where: 'id = ?', whereArgs: [id]);
  }
}
