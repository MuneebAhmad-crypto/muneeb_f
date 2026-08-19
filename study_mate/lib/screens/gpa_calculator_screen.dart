import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';

class GpaCalculatorScreen extends StatefulWidget {
  const GpaCalculatorScreen({super.key});

  @override
  State<GpaCalculatorScreen> createState() => _GpaCalculatorScreenState();
}

class _GpaCalculatorScreenState extends State<GpaCalculatorScreen> {
  final List<CourseMarkEntry> _courses = [CourseEntry()];

  double _marksToGradePoint(double marks, double total) {
    if (total == 0) return 0.0;
    double percentage = (marks / total) * 100;
    if (percentage >= 80) return 4.0;
    if (percentage >= 75) return 3.7;
    if (percentage >= 70) return 3.3;
    if (percentage >= 65) return 3.0;
    if (percentage >= 60) return 2.7;
    if (percentage >= 55) return 2.3;
    if (percentage >= 50) return 2.0;
    return 0.0;
  }

  double _calculateGpa() {
    double totalWeightedPoints = 0;
    int totalCredits = 0;
    for (var course in _courses) {
      if (course.credits > 0) {
        double gp = _marksToGradePoint(course.obtainedMarks, course.totalMarks);
        totalWeightedPoints += gp * course.credits;
        totalCredits += course.credits;
      }
    }
    return totalCredits == 0 ? 0.0 : totalWeightedPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final gpa = _calculateGpa();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('GPA Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('Estimated Semester GPA', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(gpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ..._courses.asMap().entries.map((entry) => _buildCourseRow(entry.key, entry.value)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => setState(() => _courses.add(CourseEntry())),
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseRow(int index, CourseMarkEntry course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Course Name'),
                    onChanged: (val) => course.name = val,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
                  onPressed: () => setState(() => _courses.removeAt(index)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Marks'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => course.obtainedMarks = double.tryParse(val) ?? 0.0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Total'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => course.totalMarks = double.tryParse(val) ?? 100.0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(hintText: 'Credits'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => course.credits = int.tryParse(val) ?? 0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CourseMarkEntry {
  String name = '';
  double obtainedMarks = 0.0;
  double totalMarks = 100.0;
  int credits = 3;
}

// Alias for migration
typedef CourseEntry = CourseMarkEntry;
