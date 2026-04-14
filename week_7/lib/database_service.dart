import 'package:flutter/foundation.dart' show debugPrint;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();
  factory DatabaseService() => _instance;

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    final path = join(await getDatabasesPath(), 'college.db');
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE students (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            course TEXT NOT NULL
          )
        ''');
      },
    );
    debugPrint('Database opened successfully: $path');
    return database;
  }

  Future<int> insertStudent({
    required String name,
    required String course,
  }) async {
    final db = await database;
    return await db.insert('students', {
      'name': name,
      'course': course,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, Object?>>> getStudents() async {
    final db = await database;
    return await db.query('students', orderBy: 'id DESC');
  }
}
