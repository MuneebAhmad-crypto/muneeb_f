class Exam {
  final String id;
  final String title;
  final String courseId;
  final DateTime dateTime;
  final String? room;
  final String? notes;
  final String? courseName; // Helper for UI

  Exam({
    required this.id,
    required this.title,
    required this.courseId,
    required this.dateTime,
    this.room,
    this.notes,
    this.courseName,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      courseId: json['course_id']?.toString() ?? '',
      dateTime: DateTime.parse(json['date_time'] ?? DateTime.now().toIso8601String()),
      room: json['room']?.toString(),
      notes: json['notes']?.toString(),
      courseName: json['sm_courses']?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'course_id': courseId,
      'date_time': dateTime.toIso8601String(),
      'room': room,
      'notes': notes,
    };
  }
}
