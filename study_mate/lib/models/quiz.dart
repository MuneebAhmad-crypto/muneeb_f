class Quiz {
  final String id;
  final String? courseId;
  final String title;
  final String? courseName;
  final int totalQuestions;
  final double? lastScore;
  final DateTime? quizDate;
  final DateTime createdAt;

  Quiz({
    required this.id,
    this.courseId,
    required this.title,
    this.courseName,
    this.totalQuestions = 0,
    this.lastScore,
    this.quizDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'total_questions': totalQuestions,
      'last_score': lastScore,
      'quiz_date': quizDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString(),
      title: json['title']?.toString() ?? 'Untitled',
      courseName: json['sm_courses']?['name']?.toString(),
      totalQuestions: (json['total_questions'] as num?)?.toInt() ?? 0,
      lastScore: json['last_score'] != null ? (json['last_score'] as num).toDouble() : null,
      quizDate: json['quiz_date'] != null ? DateTime.parse(json['quiz_date']) : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
