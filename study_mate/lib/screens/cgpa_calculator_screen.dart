import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';

class CgpaCalculatorScreen extends StatefulWidget {
  const CgpaCalculatorScreen({super.key});

  @override
  State<CgpaCalculatorScreen> createState() => _CgpaCalculatorScreenState();
}

class _CgpaCalculatorScreenState extends State<CgpaCalculatorScreen> {
  final List<SemesterEntry> _semesters = [SemesterEntry()];

  double _calculateCgpa() {
    double totalPoints = 0;
    int totalCredits = 0;
    for (var sem in _semesters) {
      if (sem.credits > 0) {
        totalPoints += sem.gpa * sem.credits;
        totalCredits += sem.credits;
      }
    }
    return totalCredits == 0 ? 0.0 : totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final cgpa = _calculateCgpa();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('CGPA Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
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
                color: AppTheme.tertiary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppTheme.tertiary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: Column(
                children: [
                  const Text('Cumulative GPA', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(cgpa.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ..._semesters.asMap().entries.map((entry) => _buildSemesterRow(entry.key, entry.value)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => setState(() => _semesters.add(SemesterEntry())),
              icon: const Icon(Icons.add),
              label: const Text('Add Semester'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterRow(int index, SemesterEntry sem) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextField(
              decoration: InputDecoration(hintText: 'Semester ${index + 1} GPA'),
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => sem.gpa = double.tryParse(val) ?? 0.0),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(hintText: 'Credits'),
              keyboardType: TextInputType.number,
              onChanged: (val) => setState(() => sem.credits = int.tryParse(val) ?? 0),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.error),
            onPressed: () {
              if (_semesters.length > 1) {
                setState(() => _semesters.removeAt(index));
              }
            },
          ),
        ],
      ),
    );
  }
}

class SemesterEntry {
  double gpa = 0.0;
  int credits = 0;
}
