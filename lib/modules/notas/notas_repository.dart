import '../../core/database/database_helper.dart';
import '../../models/nota.dart';

class NotasRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Nota>> obtenerTodas() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'notas',
      orderBy: 'fijada DESC, actualizada_en DESC',
    );
    return maps.map((m) => Nota.fromMap(m)).toList();
  }

  Future<int> crear(Nota nota) async {
    final db = await _dbHelper.database;
    return db.insert('notas', nota.toMap());
  }

  Future<int> actualizar(Nota nota) async {
    final db = await _dbHelper.database;
    return db.update('notas', nota.toMap(), where: 'id = ?', whereArgs: [nota.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('notas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> alternarFijada(int id, bool fijada) async {
    final db = await _dbHelper.database;
    return db.update('notas', {'fijada': fijada ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
