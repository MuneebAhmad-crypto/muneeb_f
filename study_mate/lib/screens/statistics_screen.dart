import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/assignment_provider.dart';
import 'package:study_mate/providers/attendance_provider.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/exam_provider.dart';
import 'package:study_mate/providers/quiz_provider.dart';
import 'package:study_mate/providers/task_provider.dart';
import 'package:study_mate/models/assignment.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final courses = Provider.of<CourseProvider>(context).courses;
    final assignments = Provider.of<AssignmentProvider>(context).assignments;
    final exams = Provider.of<ExamProvider>(context).exams;
    final tasks = Provider.of<TaskProvider>(context).tasks;
    final quizzes = Provider.of<QuizProvider>(context).quizzes;
    final attProv = Provider.of<AttendanceProvider>(context);

    final completedAssignments = assignments.where((a) => a.status == AssignmentStatus.completed).length;
    final totalAssignments = assignments.length;
    final completedTasks = tasks.where((t) => t.isCompleted).length;
    final totalTasks = tasks.length;

    int totalPresent = 0;
    int totalClasses = 0;
    attProv.stats.forEach((cid, stat) {
      totalPresent += stat['present'] ?? 0;
      totalClasses += stat['total'] ?? 0;
    });
    final overallAttendance = totalClasses == 0 ? 0.0 : (totalPresent / totalClasses) * 100;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Academic Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: AppTheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview & Performance', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text('Live statistics computed from your StudyMate records', style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 24),

                // Stat Cards Grid
                GridView.count(
                  crossAxisCount: MediaQuery.of(context).size.width >= 768 ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildStatCard('Enrolled Courses', '${courses.length}', Icons.book, AppTheme.primary),
                    _buildStatCard('Avg Attendance', '${overallAttendance.toInt()}%', Icons.fact_check, const Color(0xFF14B8A6)),
                    _buildStatCard('Assignments Done', '$completedAssignments / $totalAssignments', Icons.assignment_turned_in, AppTheme.secondaryContainer),
                    _buildStatCard('Tasks Completed', '$completedTasks / $totalTasks', Icons.check_circle_outline, Colors.green),
                  ],
                ),

                const SizedBox(height: 32),
                const Text('Course Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                if (courses.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('No course data available yet.', style: TextStyle(color: AppTheme.onSurfaceVariant))),
                  )
                else
                  ...courses.map((course) {
                    final stats = attProv.stats[course.id] ?? {'present': 0, 'absent': 0, 'total': 0};
                    final present = stats['present']!;
                    final total = stats['total']!;
                    final pct = total == 0 ? 0.0 : (present / total);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(course.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${(pct * 100).toInt()}% Attendance', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: AppTheme.surfaceVariant,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 32),
                const Text('Additional Metrics', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      _buildMetricRow('Upcoming Exams', '${exams.length} scheduled'),
                      const Divider(),
                      _buildMetricRow('Quizzes Logged', '${quizzes.length} total'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
