import 'package:flutter/material.dart';
import 'package:study_mate/models/course.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class CourseProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Course> _courses = [];
  bool _isLoading = false;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;

  Future<void> fetchCourses() async {
    _isLoading = true;
    notifyListeners();
    try {
      _courses = await _supabaseService.getCourses();
    } catch (e) {
      debugPrint('Error fetching courses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCourse(Course course) async {
    try {
      await _supabaseService.addCourse(course);
      await fetchCourses();
    } catch (e) {
      debugPrint('Error adding course: $e');
    }
  }
}
