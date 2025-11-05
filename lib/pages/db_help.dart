import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_help.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('measurements.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material TEXT,
        frequency REAL,
        p1 REAL,
        p2 REAL,
        absorption REAL,
        createdAt TEXT
      )
    ''');
  }

  Future<int> insertMeasurement(Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.insert('measurements', data);
  }

  Future<List<Map<String, dynamic>>> getAllMeasurements() async {
    final db = await instance.database;
    return await db.query('measurements');
  }

  Future<void> clearAll() async {
    final db = await instance.database;
    await db.delete('measurements');
  }
}
