import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  FirebaseFirestore? _firestore;

  FirebaseFirestore get firestore {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore!;
    } catch (e) {
      rethrow;
    }
  }

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  // Add task to Firestore
  Future<String> addTask(Task task) async {
    try {
      final docRef = await firestore
          .collection('users')
          .doc(task.userId)
          .collection('tasks')
          .add({
            'title': task.title,
            'description': task.description,
            'status': task.status,
            'createdAt': task.createdAt,
            'updatedAt': DateTime.now(),
            'isSynced': true,
          });
      return docRef.id;
    } catch (e) {
      rethrow;
    }
  }

  // Update task in Firestore
  Future<void> updateTask(Task task) async {
    try {
      await firestore
          .collection('users')
          .doc(task.userId)
          .collection('tasks')
          .doc(task.id)
          .update({
            'title': task.title,
            'description': task.description,
            'status': task.status,
            'updatedAt': DateTime.now(),
          });
    } catch (e) {
      rethrow;
    }
  }

  // Delete task from Firestore
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(taskId)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get tasks from Firestore (real-time)
  Stream<List<Task>> getTasks(String userId) {
    try {
      return firestore
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map(
                  (doc) => Task.fromJson({
                    ...doc.data(),
                    'id': doc.id,
                    'userId': userId,
                    'isSynced': true,
                  }),
                )
                .toList();
          });
    } catch (e) {
      rethrow;
    }
  }

  // Sync local unsync tasks to Firestore
  Future<SyncResult> syncTasks(String userId, List<Task> unsyncTasks) async {
    int successCount = 0;
    int failureCount = 0;
    List<String> failedTaskIds = [];

    for (final task in unsyncTasks) {
      try {
        if (task.id != null) {
          await updateTask(task);
        } else {
          await addTask(task);
        }
        successCount++;
      } catch (e) {
        failureCount++;
        failedTaskIds.add(task.id ?? 'unknown');
      }
    }

    return SyncResult(
      success: failureCount == 0,
      successCount: successCount,
      failureCount: failureCount,
      failedTaskIds: failedTaskIds,
      message:
          'Synced $successCount tasks${failureCount > 0 ? ', $failureCount failed' : ''}',
    );
  }
}

class SyncResult {
  final bool success;
  final int successCount;
  final int failureCount;
  final List<String> failedTaskIds;
  final String message;

  SyncResult({
    required this.success,
    required this.successCount,
    required this.failureCount,
    required this.failedTaskIds,
    required this.message,
  });
}
