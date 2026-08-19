import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/task.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class TaskProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Task> _tasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final records = await _supabaseService.getTasks();
      _tasks = records.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching tasks serving cached...');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, {DateTime? dueDate}) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      isCompleted: false,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    // 1. Instant UI update
    _tasks.insert(0, task);
    notifyListeners();

    // 2. Background sync
    _supabaseService.addTask(title, dueDate).catchError((e) => null);
  }

  Future<void> toggleTaskStatus(String id, bool isCompleted) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final old = _tasks[index];
      _tasks[index] = Task(
        id: old.id,
        title: old.title,
        isCompleted: isCompleted,
        dueDate: old.dueDate,
        createdAt: old.createdAt,
      );
      notifyListeners();

      // Background sync
      _supabaseService.client
          .from('sm_tasks')
          .update({'is_completed': isCompleted}).eq('id', id)
          .then((_) => null).catchError((e) => null);
    }
  }

  Future<void> deleteTask(String id) async {
    // Instant delete
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();

    // Background sync
    _supabaseService.client.from('sm_tasks').delete().eq('id', id)
        .then((_) => null).catchError((e) => null);
  }
}
