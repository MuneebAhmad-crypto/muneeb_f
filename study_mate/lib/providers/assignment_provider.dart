import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Assignment> _assignments = [];
  bool _isLoading = false;

  List<Assignment> get assignments => _assignments;
  bool get isLoading => _isLoading;

  Future<void> fetchAssignments() async {
    _isLoading = true;
    
    // 1. Instant load from local cache
    try {
      final cached = await _supabaseService.getAssignmentsFromCache();
      if (cached.isNotEmpty) {
        _assignments = cached;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    // 2. Refresh from remote
    try {
      _assignments = await _supabaseService.getAssignments();
    } catch (e) {
      debugPrint('Error fetching assignments: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAssignment(String title, String courseId, DateTime dueDate) async {
    final assignment = Assignment(
      id: _uuid.v4(),
      title: title,
      courseId: courseId,
      dueDate: dueDate,
      status: AssignmentStatus.pending,
    );

    // 1. Instant UI Update
    _assignments.insert(0, assignment);
    notifyListeners();

    // 2. Background Sync (Non-blocking)
    _supabaseService.addAssignment(assignment).catchError((e) => null);
  }

  Future<void> toggleAssignmentStatus(String id, bool isCompleted) async {
    final index = _assignments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _assignments[index];
      final updated = Assignment(
        id: old.id,
        title: old.title,
        description: old.description,
        courseId: old.courseId,
        dueDate: old.dueDate,
        status: isCompleted ? AssignmentStatus.completed : AssignmentStatus.pending,
        priority: old.priority,
        courseName: old.courseName,
      );
      
      // 1. Instant UI Update
      _assignments[index] = updated;
      notifyListeners();

      // 2. Background Sync
      _supabaseService.updateAssignment(updated).catchError((e) => null);
    }
  }

  Future<void> deleteAssignment(String id) async {
    // 1. Instant UI Update
    _assignments.removeWhere((a) => a.id == id);
    notifyListeners();

    // 2. Background Sync
    _supabaseService.deleteAssignment(id).catchError((e) => null);
  }
}
