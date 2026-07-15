import 'package:shared_preferences/shared_preferences.dart';
import 'note.dart';

class StorageService {
  static const String key = "notes";

  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> noteList =
    notes.map((e) => e.toJson()).toList();

    await prefs.setStringList(key, noteList);
  }

  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();

    List<String>? noteList =
    prefs.getStringList(key);

    if (noteList == null) return [];

    return noteList
        .map((e) => Note.fromJson(e))
        .toList();
  }
}