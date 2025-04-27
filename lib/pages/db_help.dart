import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DBHelper {
  static Database? _database;
  static final DBHelper instance = DBHelper._internal();

  DBHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'impedance_tube.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE measurements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    micSpacing REAL,
    distanceSample REAL,
    tubeDiameter REAL,
    freqMin INTEGER,
    freqMax INTEGER,
    samplingRate INTEGER,
    absorptionCoefficients TEXT,  -- new field
    createdAt TEXT
  )
''');

  }

  Future<int> insertMeasurement(Map<String, dynamic> data) async {
    Database db = await instance.database;
    return await db.insert('measurements', data);
  }

  Future<List<Map<String, dynamic>>> getMeasurements() async {
    Database db = await instance.database;
    return await db.query('measurements', orderBy: 'createdAt DESC');
  }

  Future<int> deleteMeasurement(int id) async {
    Database db = await instance.database;
    return await db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }
}
