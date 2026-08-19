import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/assignment_provider.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/screens/add_assignment_screen.dart';
import 'package:intl/intl.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    final assignments = assignmentProvider.assignments;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Assignments', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: assignmentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : assignments.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    return _buildAssignmentCard(context, assignments[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAssignmentScreen()));
        },
        backgroundColor: AppTheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          Text('No assignments yet', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          const Text('Tap the + button to add your tasks.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(BuildContext context, Assignment assignment) {
    final isCompleted = assignment.status == AssignmentStatus.completed;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Checkbox(
          value: isCompleted,
          onChanged: (val) {
            Provider.of<AssignmentProvider>(context, listen: false).toggleAssignmentStatus(assignment.id, val!);
          },
          activeColor: AppTheme.secondary,
        ),
        title: Text(
          assignment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            color: isCompleted ? AppTheme.onSurfaceVariant : AppTheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(assignment.courseName ?? 'General', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              'Due: ${DateFormat('MMM d, yyyy').format(assignment.dueDate)}',
              style: TextStyle(fontSize: 12, color: assignment.dueDate.isBefore(DateTime.now()) && !isCompleted ? AppTheme.error : AppTheme.outline),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppTheme.error),
          onPressed: () => _showDeleteDialog(context, assignment),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Assignment assignment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assignment'),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await Provider.of<AssignmentProvider>(context, listen: false).deleteAssignment(assignment.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
