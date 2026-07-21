class Calculation {
  final int id;
  final String expression;
  final String result;

  Calculation({
    required this.id,
    required this.expression,
    required this.result,
  });

  factory Calculation.fromJson(Map<String, dynamic> json) {
    return Calculation(
      id: json['id'],
      expression: json['expression'],
      result: json['result'],
    );
  }
}