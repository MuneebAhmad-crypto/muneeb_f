enum AssignmentStatus { pending, completed, overdue }
enum AssignmentPriority { low, medium, high }

class Assignment {
  final String id;
  final String title;
  final String? description;
  final String courseId;
  final DateTime dueDate;
  final AssignmentStatus status;
  final AssignmentPriority priority;
  final String? courseName; // Helper for UI

  Assignment({
    required this.id,
    required this.title,
    this.description,
    required this.courseId,
    required this.dueDate,
    this.status = AssignmentStatus.pending,
    this.priority = AssignmentPriority.medium,
    this.courseName,
  });

  bool get isOverdue => status != AssignmentStatus.completed && dueDate.isBefore(DateTime.now());

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString(),
      courseId: json['course_id']?.toString() ?? '',
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      status: AssignmentStatus.values.firstWhere(
        (e) => e.name == json['status'], 
        orElse: () => AssignmentStatus.pending
      ),
      priority: AssignmentPriority.values.firstWhere(
        (e) => e.name == json['priority'], 
        orElse: () => AssignmentPriority.medium
      ),
      courseName: json['sm_courses']?['name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'course_id': courseId,
      'due_date': dueDate.toIso8601String(),
      'status': status.name,
      'priority': priority.name,
    };
  }
}
