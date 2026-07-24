import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'calculation_history.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('calculator_history.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Insert calculation
  Future<int> insertHistory(CalculationHistory item) async {
    final db = await instance.database;
    return await db.insert('history', item.toMap());
  }

  // Get all calculation history items (newest first)
  Future<List<CalculationHistory>> getHistory() async {
    final db = await instance.database;
    final maps = await db.query('history', orderBy: 'id DESC');
    return maps.map((map) => CalculationHistory.fromMap(map)).toList();
  }

  // Delete single history item
  Future<int> deleteHistoryItem(int id) async {
    final db = await instance.database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all history
  Future<int> clearAllHistory() async {
    final db = await instance.database;
    return await db.delete('history');
  }
}