class Course {
  final String id;
  final String name;
  final String code;
  final String? teacher;
  final int creditHours;
  final String? color;
  final String? icon;

  Course({
    required this.id,
    required this.name,
    required this.code,
    this.teacher,
    required this.creditHours,
    this.color,
    this.icon,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled',
      code: json['code']?.toString() ?? 'N/A',
      teacher: json['teacher']?.toString(),
      creditHours: (json['credit_hours'] as num?)?.toInt() ?? 3,
      color: json['color']?.toString(),
      icon: json['icon']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'teacher': teacher,
      'credit_hours': creditHours,
      'color': color,
      'icon': icon,
    };
  }
}
