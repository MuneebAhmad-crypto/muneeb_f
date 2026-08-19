import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:study_mate/models/note.dart';
import 'package:study_mate/models/flashcard.dart';

class LocalDatabaseService {
  static final LocalDatabaseService _instance = LocalDatabaseService._internal();
  factory LocalDatabaseService() => _instance;
  LocalDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'study_mate_local.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN file_path TEXT');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. NOTES Table
    await db.execute('''
      CREATE TABLE notes(
        id TEXT PRIMARY KEY,
        course_id TEXT,
        title TEXT NOT NULL,
        content TEXT,
        file_path TEXT,
        is_favorite INTEGER DEFAULT 0,
        folder_name TEXT DEFAULT 'General',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 2. FLASHCARDS Table
    await db.execute('''
      CREATE TABLE flashcards(
        id TEXT PRIMARY KEY,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        course_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // NOTES CRUD
  Future<void> insertNote(Note note) async {
    final db = await database;
    await db.insert(
      'notes', 
      note.toLocalMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Note>> getNotes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('notes', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => Note.fromLocalMap(maps[i]));
  }

  Future<void> deleteNote(String id) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote(Note note) async {
    final db = await database;
    await db.update('notes', note.toLocalMap(), where: 'id = ?', whereArgs: [note.id]);
  }

  // FLASHCARDS CRUD
  Future<void> insertFlashcard(Flashcard card) async {
    final db = await database;
    await db.insert(
      'flashcards', 
      card.toLocalMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Flashcard>> getFlashcards() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('flashcards', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Flashcard.fromLocalMap(maps[i]));
  }

  Future<void> deleteFlashcard(String id) async {
    final db = await database;
    await db.delete('flashcards', where: 'id = ?', whereArgs: [id]);
  }
}
