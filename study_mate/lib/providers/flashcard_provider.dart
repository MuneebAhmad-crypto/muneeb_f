import 'package:flutter/material.dart';
import 'package:study_mate/models/flashcard.dart';
import 'package:study_mate/core/services/local_database_service.dart';
import 'package:uuid/uuid.dart';

class FlashcardProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  List<Flashcard> _flashcards = [];
  bool _isLoading = false;

  List<Flashcard> get flashcards => _flashcards;
  bool get isLoading => _isLoading;

  Future<void> fetchFlashcards() async {
    _isLoading = true;
    notifyListeners();
    _flashcards = await _localDb.getFlashcards();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addFlashcard(String question, String answer, {String? courseId}) async {
    final card = Flashcard(
      id: const Uuid().v4(),
      question: question,
      answer: answer,
      courseId: courseId,
      createdAt: DateTime.now(),
    );
    await _localDb.insertFlashcard(card);
    await fetchFlashcards();
  }

  Future<void> deleteFlashcard(String id) async {
    await _localDb.deleteFlashcard(id);
    await fetchFlashcards();
  }
}
