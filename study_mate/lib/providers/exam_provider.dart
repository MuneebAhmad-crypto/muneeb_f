import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/exam.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class ExamProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Exam> _exams = [];
  bool _isLoading = false;

  List<Exam> get exams => _exams;
  bool get isLoading => _isLoading;

  Future<void> fetchExams() async {
    _isLoading = true;
    
    // 1. Instant load from local cache
    try {
      final cached = await _supabaseService.getExamsFromCache();
      if (cached.isNotEmpty) {
        _exams = cached;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    // 2. Refresh from remote
    try {
      _exams = await _supabaseService.getExams();
    } catch (e) {
      debugPrint('Error fetching exams: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExam(String title, String courseId, DateTime dateTime, String? room) async {
    final exam = Exam(
      id: _uuid.v4(),
      title: title,
      courseId: courseId,
      dateTime: dateTime,
      room: room,
    );

    // 1. Instant UI update
    _exams.insert(0, exam);
    notifyListeners();

    // 2. Background Sync
    _supabaseService.addExam(exam).catchError((e) => null);
  }

  Future<void> deleteExam(String id) async {
    // 1. Instant UI update
    _exams.removeWhere((e) => e.id == id);
    notifyListeners();

    // 2. Background Sync
    _supabaseService.deleteExam(id).catchError((e) => null);
  }
}
