import '../../core/database/database_helper.dart';
import '../../models/evento_calendario.dart';

class CalendarioRepository {
  final _dbHelper = DatabaseHelper.instance;

  Future<List<EventoCalendario>> obtenerTodos() async {
    final db = await _dbHelper.database;
    final maps = await db.query('eventos_calendario', orderBy: 'fecha ASC');
    return maps.map((m) => EventoCalendario.fromMap(m)).toList();
  }

  /// Próximos eventos no completados, a partir de hoy, ordenados por fecha.
  Future<List<EventoCalendario>> obtenerProximos({int limite = 5}) async {
    final db = await _dbHelper.database;
    final hoy = DateTime.now();
    final desde = DateTime(hoy.year, hoy.month, hoy.day);
    final maps = await db.query(
      'eventos_calendario',
      where: 'fecha >= ? AND completado = 0',
      whereArgs: [desde.toIso8601String()],
      orderBy: 'fecha ASC',
      limit: limite,
    );
    return maps.map((m) => EventoCalendario.fromMap(m)).toList();
  }

  Future<int> crear(EventoCalendario evento) async {
    final db = await _dbHelper.database;
    return db.insert('eventos_calendario', evento.toMap());
  }

  Future<int> actualizar(EventoCalendario evento) async {
    final db = await _dbHelper.database;
    return db.update('eventos_calendario', evento.toMap(),
        where: 'id = ?', whereArgs: [evento.id]);
  }

  Future<int> eliminar(int id) async {
    final db = await _dbHelper.database;
    return db.delete('eventos_calendario', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> marcarCompletado(int id, bool completado) async {
    final db = await _dbHelper.database;
    return db.update(
      'eventos_calendario',
      {'completado': completado ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
