import 'package:flutter/material.dart';
import 'package:study_mate/models/note.dart';
import 'package:study_mate/core/services/local_database_service.dart';
import 'package:uuid/uuid.dart';

class NoteProvider extends ChangeNotifier {
  final LocalDatabaseService _localDb = LocalDatabaseService();
  List<Note> _notes = [];
  bool _isLoading = false;

  List<Note> get notes => _notes;
  bool get isLoading => _isLoading;

  Future<void> fetchNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = await _localDb.getNotes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(String title, String content, {String? courseId, String? filePath}) async {
    final now = DateTime.now();
    final note = Note(
      id: const Uuid().v4(),
      title: title,
      content: content,
      courseId: courseId,
      filePath: filePath,
      createdAt: now,
      updatedAt: now,
    );
    await _localDb.insertNote(note);
    await fetchNotes();
  }

  Future<void> updateNote(Note note) async {
    final updatedNote = Note(
      id: note.id,
      title: note.title,
      content: note.content,
      courseId: note.courseId,
      filePath: note.filePath,
      isFavorite: note.isFavorite,
      folderName: note.folderName,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
    );
    await _localDb.updateNote(updatedNote);
    await fetchNotes();
  }

  Future<void> deleteNote(String id) async {
    await _localDb.deleteNote(id);
    await fetchNotes();
  }
}
