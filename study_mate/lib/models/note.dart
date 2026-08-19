class Note {
  final String id;
  final String? courseId;
  final String title;
  final String content;
  final String? filePath; // New field for PDF/PPT
  final bool isFavorite;
  final String folderName;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note({
    required this.id,
    this.courseId,
    required this.title,
    required this.content,
    this.filePath,
    this.isFavorite = false,
    this.folderName = 'General',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'content': content,
      'file_path': filePath,
      'is_favorite': isFavorite ? 1 : 0,
      'folder_name': folderName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Note.fromLocalMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      content: map['content'],
      filePath: map['file_path'],
      isFavorite: map['is_favorite'] == 1,
      folderName: map['folder_name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
