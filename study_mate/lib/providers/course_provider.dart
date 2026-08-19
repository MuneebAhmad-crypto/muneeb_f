import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/course.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class CourseProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    
    // 1. Instant load from local cache
    try {
      final cached = await _supabaseService.getCoursesFromCache();
      if (cached.isNotEmpty) {
        _courses = cached;
        _isLoading = false; 
        notifyListeners();
      }
    } catch (_) {}

    // 2. Refresh from remote in background
    try {
      final remote = await _supabaseService.getCourses();
      _courses = remote;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(String name, String code, String teacher, int creditHours) async {
    final newCourse = Course(
      id: _uuid.v4(),
      name: name,
      code: code,
      teacher: teacher,
      creditHours: creditHours,
    );

    // 1. Instant UI Update
    _courses.insert(0, newCourse);
    notifyListeners();

    // 2. Background Network Sync (Non-blocking)
    _supabaseService.addCourse(newCourse).catchError((e) {
      debugPrint('Background sync failed for addCourse: $e');
    });
  }

  Future<void> updateCourse(Course course) async {
    final index = _courses.indexWhere((c) => c.id == course.id);
    if (index != -1) {
      _courses[index] = course;
      notifyListeners();
    }
    // Background Sync
    _supabaseService.updateCourse(course).catchError((e) => null);
  }

  Future<void> deleteCourse(String id) async {
    _courses.removeWhere((c) => c.id == id);
    notifyListeners();
    // Background Sync
    _supabaseService.deleteCourse(id).catchError((e) => null);
  }
}
