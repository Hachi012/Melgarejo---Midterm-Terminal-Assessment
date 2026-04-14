import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'strm_tasks.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        isSynced INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  // Add a new task
  Future<Task> addTask(Task task) async {
    final db = await database;
    await db.insert('tasks', {
      'id': task.id,
      'userId': task.userId,
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt?.toIso8601String(),
      'isSynced': task.isSynced ? 1 : 0,
    });
    return task;
  }

  // Get all tasks for a user
  Future<List<Task>> getTasksByUserId(String userId) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
    return results.map((json) => Task.fromJson(_convertToMap(json))).toList();
  }

  // Get unsync tasks
  Future<List<Task>> getUnsyncTasks(String userId) async {
    final db = await database;
    final results = await db.query(
      'tasks',
      where: 'userId = ? AND isSynced = 0',
      whereArgs: [userId],
    );
    return results.map((json) => Task.fromJson(_convertToMap(json))).toList();
  }

  // Update task
  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      {
        'title': task.title,
        'description': task.description,
        'status': task.status,
        'updatedAt': task.updatedAt?.toIso8601String(),
        'isSynced': task.isSynced ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  // Delete task
  Future<int> deleteTask(String taskId) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
  }

  // Mark task as synced
  Future<int> markTaskAsSynced(String taskId) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'isSynced': 1},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  Map<String, dynamic> _convertToMap(Map<dynamic, dynamic> json) {
    return json.cast<String, dynamic>();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
