import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/widgets/inputs/custom_text_field.dart';

class PercentageCalculatorScreen extends StatefulWidget {
  const PercentageCalculatorScreen({super.key});

  @override
  State<PercentageCalculatorScreen> createState() => _PercentageCalculatorScreenState();
}

class _PercentageCalculatorScreenState extends State<PercentageCalculatorScreen> {
  final _marksController = TextEditingController();
  final _totalController = TextEditingController();
  String _result = '0.0%';

  void _calculate() {
    double marks = double.tryParse(_marksController.text) ?? 0;
    double total = double.tryParse(_totalController.text) ?? 0;
    if (total > 0) {
      setState(() {
        _result = '${((marks / total) * 100).toStringAsFixed(1)}%';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Percentage Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Result', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(_result, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(label: 'Obtained Marks', hintText: 'e.g. 85', prefixIcon: Icons.edit_note, controller: _marksController, keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            CustomTextField(label: 'Total Marks', hintText: 'e.g. 100', prefixIcon: Icons.summarize_outlined, controller: _totalController, keyboardType: TextInputType.number),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
          ],
        ),
      ),
    );
  }
}
