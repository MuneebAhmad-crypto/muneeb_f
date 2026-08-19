class Flashcard {
  final String id;
  final String question;
  final String answer;
  final String? courseId;
  final DateTime createdAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.courseId,
    required this.createdAt,
  });

  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'course_id': courseId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Flashcard.fromLocalMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
      courseId: map['course_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
