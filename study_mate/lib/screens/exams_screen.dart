import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/exam_provider.dart';
import 'package:study_mate/models/exam.dart';
import 'package:study_mate/screens/add_exam_screen.dart';
import 'package:intl/intl.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final examProvider = Provider.of<ExamProvider>(context);
    final exams = examProvider.exams;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Exams', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: examProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : exams.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  itemBuilder: (context, index) {
                    return _buildExamCard(context, exams[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExamScreen()));
        },
        backgroundColor: AppTheme.error,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No exams scheduled', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text("Stay prepared!", style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context, Exam exam) {
    final diff = exam.dateTime.difference(DateTime.now()).inDays;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.error.withValues(alpha: 0.3)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.errorContainer, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    diff < 0 ? 'PAST' : (diff == 0 ? 'TODAY' : 'IN $diff DAYS'),
                    style: const TextStyle(color: AppTheme.error, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(exam.dateTime),
                      style: const TextStyle(fontSize: 12, color: AppTheme.outline),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                      onPressed: () => _showDeleteDialog(context, exam),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(exam.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(exam.courseName ?? 'General', style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
            const SizedBox(height: 12),
            if (exam.room != null && exam.room!.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppTheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(exam.room!, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Provider.of<ExamProvider>(context, listen: false).deleteExam(exam.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
