import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('measurements.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    String path;
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      path = join(Directory.current.path, fileName); // Desktop-safe
    } else {
      final dbPath = await getDatabasesPath();
      path = join(dbPath, fileName);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS measurements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        material TEXT NOT NULL,
        frequency REAL NOT NULL,
        p1 REAL NOT NULL,
        p2 REAL NOT NULL,
        absorption REAL NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertMeasurement(Map<String, dynamic> data) async {
    try {
      final db = await instance.database;
      return await db.insert('measurements', data);
    } catch (e) {
      print('Insert failed: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getAllMeasurements() async {
    try {
      final db = await instance.database;
      return await db.query('measurements', orderBy: 'createdAt DESC');
    } catch (e) {
      print('Query failed: $e');
      return [];
    }
  }

  Future<void> clearAll() async {
    try {
      final db = await instance.database;
      await db.delete('measurements');
    } catch (e) {
      print('Clear failed: $e');
    }
  }

  Future<int> deleteMeasurement(int id) async {
    final db = await instance.database;
    return await db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }
}

