import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Punto único de acceso a la base de datos SQLite local.
/// Toda la información se almacena exclusivamente en el dispositivo,
/// sin ninguna sincronización remota.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  /// En Windows/Linux de escritorio, sqflite no tiene motor nativo propio:
  /// hay que usar sqflite_common_ffi. En Android/iOS (el destino real de la
  /// app, incluido el iPad) se usa el sqflite normal sin tocar nada.
  void _configurarFactorySegunPlataforma() {
    if (kIsWeb) return;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<Database> _initDatabase() async {
    _configurarFactorySegunPlataforma();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'agro_app.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  /// Migraciones incrementales: se ejecutan solo si ya existía una base de
  /// datos de una versión anterior, para no perder los datos cargados.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS notas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          titulo TEXT NOT NULL,
          contenido TEXT NOT NULL,
          fijada INTEGER DEFAULT 0,
          creada_en TEXT NOT NULL,
          actualizada_en TEXT NOT NULL
        )
      ''');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // ---------------- CULTIVOS ----------------
    batch.execute('''
      CREATE TABLE lotes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        numero TEXT,
        superficie REAL,
        tipo_cultivo TEXT,
        fecha_siembra TEXT,
        fecha_cosecha_estimada TEXT,
        estado TEXT DEFAULT 'Sembrado',
        observaciones TEXT,
        creado_en TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE lote_labores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER NOT NULL,
        tipo TEXT NOT NULL, -- fertilizacion | aplicacion | riego | produccion
        fecha TEXT NOT NULL,
        producto TEXT,
        dosis TEXT,
        cantidad REAL,
        unidad TEXT,
        observaciones TEXT,
        FOREIGN KEY (lote_id) REFERENCES lotes (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE TABLE lote_fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lote_id INTEGER NOT NULL,
        ruta_archivo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (lote_id) REFERENCES lotes (id) ON DELETE CASCADE
      )
    ''');

    // ---------------- GANADO ----------------
    batch.execute('''
      CREATE TABLE animales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        caravana TEXT NOT NULL,
        nombre TEXT,
        sexo TEXT,
        raza TEXT,
        fecha_nacimiento TEXT,
        peso REAL,
        estado_sanitario TEXT,
        activo INTEGER DEFAULT 1,
        creado_en TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE animal_eventos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL,
        tipo TEXT NOT NULL, -- vacuna | tratamiento | reproduccion | compra | venta | fallecimiento | observacion
        fecha TEXT NOT NULL,
        detalle TEXT,
        monto REAL,
        FOREIGN KEY (animal_id) REFERENCES animales (id) ON DELETE CASCADE
      )
    ''');
    batch.execute('''
      CREATE TABLE animal_fotos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        animal_id INTEGER NOT NULL,
        ruta_archivo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        FOREIGN KEY (animal_id) REFERENCES animales (id) ON DELETE CASCADE
      )
    ''');

    // ---------------- MAQUINARIA ----------------
    batch.execute('''
      CREATE TABLE maquinarias (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        marca TEXT,
        modelo TEXT,
        anio INTEGER,
        horas_uso REAL DEFAULT 0,
        estado TEXT DEFAULT 'Operativo',
        creado_en TEXT NOT NULL
      )
    ''');
    batch.execute('''
      CREATE TABLE maquinaria_mantenimientos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        maquinaria_id INTEGER NOT NULL,
        tipo TEXT NOT NULL, -- mantenimiento | cambio_aceite | reparacion | combustible
        fecha TEXT NOT NULL,
        descripcion TEXT,
        costo REAL,
        proximo_servicio TEXT,
        FOREIGN KEY (maquinaria_id) REFERENCES maquinarias (id) ON DELETE CASCADE
      )
    ''');

    // ---------------- FINANZAS ----------------
    batch.execute('''
      CREATE TABLE movimientos_financieros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo TEXT NOT NULL, -- ingreso | egreso
        fecha TEXT NOT NULL,
        concepto TEXT NOT NULL,
        categoria TEXT,
        monto REAL NOT NULL,
        observaciones TEXT,
        creado_en TEXT NOT NULL
      )
    ''');

    // ---------------- CALENDARIO ----------------
    batch.execute('''
      CREATE TABLE eventos_calendario (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        tipo TEXT NOT NULL, -- vacunacion | siembra | cosecha | fertilizacion | reparacion | recordatorio | vencimiento
        fecha TEXT NOT NULL,
        notas TEXT,
        notificar INTEGER DEFAULT 1,
        completado INTEGER DEFAULT 0
      )
    ''');

    // ---------------- CONFIGURACIÓN ----------------
    batch.execute('''
      CREATE TABLE configuracion (
        clave TEXT PRIMARY KEY,
        valor TEXT
      )
    ''');

    // ---------------- NOTAS ----------------
    batch.execute('''
      CREATE TABLE notas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        contenido TEXT NOT NULL,
        fijada INTEGER DEFAULT 0,
        creada_en TEXT NOT NULL,
        actualizada_en TEXT NOT NULL
      )
    ''');

    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = _db;
    if (db != null) {
      await db.close();
      _db = null;
    }
  }
}
