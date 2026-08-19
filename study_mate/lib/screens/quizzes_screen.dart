import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/quiz_provider.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/models/quiz.dart';
import 'package:intl/intl.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuizProvider>(context, listen: false).fetchQuizzes();
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
    });
  }

  void _showAddQuizDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedCourseId;
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          final courses = Provider.of<CourseProvider>(context).courses;
          
          return AlertDialog(
            title: const Text('New Quiz Schedule'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Quiz Title', hintText: 'Midterm 1'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCourseId,
                    decoration: const InputDecoration(labelText: 'Course'),
                    items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setDialogState(() => selectedCourseId = val),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateFormat('MMM d, yyyy').format(selectedDate)),
                    leading: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) setDialogState(() => selectedDate = date);
                    },
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(selectedTime.format(context)),
                    leading: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: selectedTime);
                      if (time != null) setDialogState(() => selectedTime = time);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: isSaving ? null : () async {
                  if (titleController.text.isNotEmpty) {
                    setDialogState(() => isSaving = true);
                    final dateTime = DateTime(
                      selectedDate.year, selectedDate.month, selectedDate.day,
                      selectedTime.hour, selectedTime.minute,
                    );
                    await Provider.of<QuizProvider>(context, listen: false).addQuiz(
                      titleController.text.trim(),
                      courseId: selectedCourseId,
                      quizDate: dateTime,
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: isSaving 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                  : const Text('Schedule'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Quizzes')),
      body: quizProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : quizProvider.quizzes.isEmpty
              ? _buildEmptyState(theme, context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizProvider.quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizProvider.quizzes[index];
                    return _buildQuizCard(quiz);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddQuizDialog(context),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildQuizCard(Quiz quiz) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.quiz, color: AppTheme.primary),
        ),
        title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(quiz.courseName ?? 'General', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (quiz.quizDate != null)
              Row(
                children: [
                  const Icon(Icons.event, size: 14, color: AppTheme.outline),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(quiz.quizDate!),
                    style: const TextStyle(fontSize: 12, color: AppTheme.outline),
                  ),
                ],
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: () => _showDeleteDialog(context, quiz),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Quiz quiz) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text('Are you sure you want to delete "${quiz.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final quizProv = Provider.of<QuizProvider>(context, listen: false);
              await quizProv.deleteQuiz(quiz.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz_outlined, size: 80, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('No quizzes scheduled', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap the + button to schedule your next quiz.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: () => _showAddQuizDialog(context), child: const Text('Add Quiz')),
        ],
      ),
    );
  }
}
