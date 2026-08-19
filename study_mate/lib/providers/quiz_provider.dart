import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/quiz.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class QuizProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Quiz> _quizzes = [];
  bool _isLoading = false;

  List<Quiz> get quizzes => _quizzes;
  bool get isLoading => _isLoading;

  Future<void> fetchQuizzes() async {
    _isLoading = true;
    
    try {
      final cached = await _supabaseService.getQuizzesFromCache();
      if (cached.isNotEmpty) {
        _quizzes = cached;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    try {
      _quizzes = await _supabaseService.getQuizzes();
    } catch (e) {
      debugPrint('Error fetching quizzes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuiz(String title, {String? courseId, int totalQuestions = 10, DateTime? quizDate}) async {
    final quiz = Quiz(
      id: _uuid.v4(),
      title: title,
      courseId: courseId,
      totalQuestions: totalQuestions,
      quizDate: quizDate,
      createdAt: DateTime.now(),
    );

    // 1. Instant UI update
    _quizzes.insert(0, quiz);
    notifyListeners();

    // 2. Background Sync
    _supabaseService.addQuiz(quiz).catchError((e) => null);
  }

  Future<void> deleteQuiz(String id) async {
    // 1. Instant UI update
    _quizzes.removeWhere((q) => q.id == id);
    notifyListeners();

    // 2. Background Sync
    _supabaseService.deleteQuiz(id).catchError((e) => null);
  }
}
