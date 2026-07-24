class CalculationHistory {
  final int? id;
  final String expression;
  final String result;
  final String timestamp;

  CalculationHistory({
    this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  // Convert Map from SQLite DB to Model
  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'],
      expression: map['expression'],
      result: map['result'],
      timestamp: map['timestamp'],
    );
  }

  // Convert Model to Map for SQLite DB insertion
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp,
    };
  }
}