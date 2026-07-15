import 'dart:convert';

class Note {
  String title;
  String description;

  Note({
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      description: map['description'],
    );
  }

  String toJson() => jsonEncode(toMap());

  factory Note.fromJson(String source) =>
      Note.fromMap(jsonDecode(source));
}