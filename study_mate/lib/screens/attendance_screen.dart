import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/attendance_provider.dart';
import 'package:study_mate/models/course.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courseProvider = Provider.of<CourseProvider>(context);
    final attProvider = Provider.of<AttendanceProvider>(context);
    final courses = courseProvider.courses;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Attendance', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: attProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : courses.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    final stats = attProvider.stats[course.id] ?? {'present': 0, 'absent': 0, 'total': 0};
                    return _buildCourseAttendanceCard(context, course, stats);
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fact_check_outlined, size: 80, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('No courses found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add courses to track your attendance.', style: TextStyle(color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildCourseAttendanceCard(BuildContext context, Course course, Map<String, int> stats) {
    final present = stats['present']!;
    final total = stats['total']!;
    final absent = stats['absent']!;
    final percentage = total == 0 ? 0 : (present / total) * 100;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      elevation: 0,
      borderOnForeground: true,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: AppTheme.primaryFixed, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.book, color: AppTheme.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(course.code, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
                Text('${percentage.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatItem(label: 'Total', value: '$total'),
                _StatItem(label: 'Present', value: '$present', color: Colors.green),
                _StatItem(label: 'Absent', value: '$absent', color: Colors.red),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<AttendanceProvider>(context, listen: false).markAttendance(course.id, 'present');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, minimumSize: const Size(0, 45)),
                    child: const Text('Present'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<AttendanceProvider>(context, listen: false).markAttendance(course.id, 'absent');
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(0, 45)),
                    child: const Text('Absent'),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _StatItem({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }
}
