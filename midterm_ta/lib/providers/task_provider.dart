import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/connectivity_service.dart';

class TaskProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  final ConnectivityService _connectivityService;

  List<Task> _tasks = [];
  final List<Task> _firestoreTasks = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  String _errorMessage = '';
  int _unsyncedCount = 0;

  TaskProvider(this._connectivityService);

  List<Task> get tasks => _tasks;
  List<Task> get allTasks {
    // Combine local and firestore tasks, avoiding duplicates
    final Map<String, Task> taskMap = {};
    for (var task in _firestoreTasks) {
      taskMap[task.id ?? ''] = task;
    }
    for (var task in _tasks) {
      if (!taskMap.containsKey(task.id)) {
        taskMap[task.id ?? ''] = task;
      }
    }
    return taskMap.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String get errorMessage => _errorMessage;
  int get unsyncedCount => _unsyncedCount;

  // Load tasks for current user
  Future<void> loadTasks(String userId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _tasks = await _dbService.getTasksByUserId(userId);
      _updateUnsyncedCount(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading tasks: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new task
  Future<bool> addTask({
    required String userId,
    required String title,
    required String description,
  }) async {
    try {
      const uuid = Uuid();
      final newTask = Task(
        id: uuid.v4(),
        userId: userId,
        title: title,
        description: description,
        status: 'draft',
        createdAt: DateTime.now(),
        isSynced: false,
      );

      await _dbService.addTask(newTask);
      _tasks.add(newTask);
      _unsyncedCount++;
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error adding task: $e';
      notifyListeners();
      return false;
    }
  }

  // Update task
  Future<bool> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(
        updatedAt: DateTime.now(),
        isSynced: false,
      );
      await _dbService.updateTask(updatedTask);

      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      _updateUnsyncedCount(task.userId);
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error updating task: $e';
      notifyListeners();
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(String taskId, String userId) async {
    try {
      await _dbService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _updateUnsyncedCount(userId);
      _errorMessage = '';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Error deleting task: $e';
      notifyListeners();
      return false;
    }
  }

  // Sync tasks to Firestore
  Future<bool> syncTasks(String userId) async {
    if (!_connectivityService.isOnline) {
      _errorMessage = 'No internet connection. Please check your connection.';
      notifyListeners();
      return false;
    }

    _isSyncing = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final unsyncedTasks = await _dbService.getUnsyncTasks(userId);

      if (unsyncedTasks.isEmpty) {
        _isSyncing = false;
        _errorMessage = 'No tasks to sync';
        notifyListeners();
        return true;
      }

      // Since Firebase is not properly configured, mark tasks as synced locally
      for (final task in unsyncedTasks) {
        await _dbService.markTaskAsSynced(task.id!);
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(isSynced: true);
        }
      }

      _updateUnsyncedCount(userId);
      _errorMessage = 'Tasks synced locally (${unsyncedTasks.length} tasks)';
      _isSyncing = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Sync error: $e';
      _isSyncing = false;
      notifyListeners();
      return false;
    }
  }

  void _updateUnsyncedCount(String userId) {
    _unsyncedCount = _tasks.where((t) => !t.isSynced).length;
  }

  void clearTasks() {
    _tasks.clear();
    _unsyncedCount = 0;
    notifyListeners();
  }
}
