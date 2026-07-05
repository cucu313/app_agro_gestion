import '../../core/database/database_helper.dart';
import '../../models/animal.dart';

/// Capa de acceso a datos para el módulo Ganado.
class AnimalesRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<Animal>> obtenerTodos({bool soloActivos = false}) async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'animales',
      where: soloActivos ? 'activo = 1' : null,
      orderBy: 'caravana ASC',
    );
    return maps.map((m) => Animal.fromMap(m)).toList();
  }

  Future<Animal?> obtenerPorId(int id) async {
    final db = await _dbHelper.database;
    final maps = await db.query('animales', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Animal.fromMap(maps.first);
  }

  Future<int> crear(Animal animal) async {
    final db = await _dbHelper.database;
    return db.insert('animales', animal.toMap());
  }

  Future<int> actualizar(Animal animal) async {
    final db = await _dbHelper.database;
    return db.update('animales', animal.toMap(),
        where: 'id = ?', whereArgs: [animal.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('animales', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> contarActivos() async {
    final db = await _dbHelper.database;
    final result = await db
        .rawQuery("SELECT COUNT(*) as total FROM animales WHERE activo = 1");
    return (result.first['total'] as int?) ?? 0;
  }

  // ---- Eventos del historial ----

  Future<List<AnimalEvento>> obtenerEventos(int animalId, {String? tipo}) async {
    final db = await _dbHelper.database;
    final where = tipo != null ? 'animal_id = ? AND tipo = ?' : 'animal_id = ?';
    final args = tipo != null ? [animalId, tipo] : [animalId];
    final maps = await db.query('animal_eventos',
        where: where, whereArgs: args, orderBy: 'fecha DESC');
    return maps.map((m) => AnimalEvento.fromMap(m)).toList();
  }

  Future<int> crearEvento(AnimalEvento evento) async {
    final db = await _dbHelper.database;
    return db.insert('animal_eventos', evento.toMap());
  }

  Future<int> eliminarEvento(int id) async {
    final db = await _dbHelper.database;
    return db.delete('animal_eventos', where: 'id = ?', whereArgs: [id]);
  }
}
