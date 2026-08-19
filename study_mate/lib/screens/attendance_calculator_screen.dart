import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/widgets/inputs/custom_text_field.dart';

class AttendanceCalculatorScreen extends StatefulWidget {
  const AttendanceCalculatorScreen({super.key});

  @override
  State<AttendanceCalculatorScreen> createState() => _AttendanceCalculatorScreenState();
}

class _AttendanceCalculatorScreenState extends State<AttendanceCalculatorScreen> {
  final _presentController = TextEditingController(text: '0');
  final _totalController = TextEditingController(text: '0');
  final _targetController = TextEditingController(text: '75');

  String _resultMessage = '';

  void _calculate() {
    int present = int.tryParse(_presentController.text) ?? 0;
    int total = int.tryParse(_totalController.text) ?? 0;
    int target = int.tryParse(_targetController.text) ?? 75;

    if (total == 0) return;

    double current = (present / total) * 100;
    
    if (current >= target) {
      int canMiss = 0;
      while (((present) / (total + canMiss + 1)) * 100 >= target) {
        canMiss++;
      }
      setState(() {
        _resultMessage = 'Your current attendance is ${current.toStringAsFixed(1)}%. You can miss $canMiss more classes.';
      });
    } else {
      int need = 0;
      while (((present + need) / (total + need)) * 100 < target) {
        need++;
      }
      setState(() {
        _resultMessage = 'Your current attendance is ${current.toStringAsFixed(1)}%. You need to attend $need more classes to reach $target%.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Attendance Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(label: 'Classes Attended', hintText: '0', prefixIcon: Icons.check_circle_outline, controller: _presentController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomTextField(label: 'Total Classes Held', hintText: '0', prefixIcon: Icons.calendar_month_outlined, controller: _totalController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomTextField(label: 'Target Percentage (%)', hintText: '75', prefixIcon: Icons.flag_outlined, controller: _targetController, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
            const SizedBox(height: 32),
            if (_resultMessage.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.primaryContainer)),
                child: Text(_resultMessage, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}
