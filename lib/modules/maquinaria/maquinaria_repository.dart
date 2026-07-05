import '../../core/database/database_helper.dart';
import '../../models/maquinaria.dart';

class MaquinariaRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Maquinaria>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('maquinarias', orderBy: 'nombre ASC');
    return maps.map((m) => Maquinaria.fromMap(m)).toList();
  }

  Future<Maquinaria?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('maquinarias', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Maquinaria.fromMap(maps.first);
  }

  Future<int> crear(Maquinaria m) async {
    final db = await _dbHelper.database;
    return db.insert('maquinarias', m.toMap());
  }

  Future<int> actualizar(Maquinaria m) async {
    final db = await _dbHelper.database;
    return db.update('maquinarias', m.toMap(), where: 'id = ?', whereArgs: [m.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('maquinarias', where: 'id = ?', whereArgs: [id]);
  }

  // ---- Mantenimientos ----

  Future<List<MaquinariaMantenimiento>> obtenerMantenimientos(
      int maquinariaId, {String? tipo}) async {
    final db = await _dbHelper.database;
    final where =
        tipo != null ? 'maquinaria_id = ? AND tipo = ?' : 'maquinaria_id = ?';
    final args = tipo != null ? [maquinariaId, tipo] : [maquinariaId];
    final maps = await db.query('maquinaria_mantenimientos',
        where: where, whereArgs: args, orderBy: 'fecha DESC');
    return maps.map((m) => MaquinariaMantenimiento.fromMap(m)).toList();
  }

  Future<int> crearMantenimiento(MaquinariaMantenimiento m) async {
    final db = await _dbHelper.database;
    return db.insert('maquinaria_mantenimientos', m.toMap());
  }

  Future<int> eliminarMantenimiento(int id) async {
    final db = await _dbHelper.database;
    return db.delete('maquinaria_mantenimientos', where: 'id = ?', whereArgs: [id]);
  }

  /// Próximos servicios pendientes (para mostrar avisos), ordenados por fecha.
  Future<List<MaquinariaMantenimiento>> obtenerProximosServicios() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'maquinaria_mantenimientos',
      where: 'proximo_servicio IS NOT NULL',
      orderBy: 'proximo_servicio ASC',
    );
    return maps.map((m) => MaquinariaMantenimiento.fromMap(m)).toList();
  }
}
