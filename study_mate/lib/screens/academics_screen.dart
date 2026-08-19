import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/assignment_provider.dart';
import 'package:study_mate/providers/exam_provider.dart';
import 'package:study_mate/providers/attendance_provider.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/models/exam.dart';
import 'package:intl/intl.dart';
import 'package:study_mate/screens/timetable_screen.dart';
import 'package:study_mate/screens/my_courses_screen.dart';
import 'package:study_mate/screens/assignments_screen.dart';
import 'package:study_mate/screens/exams_screen.dart';
import 'package:study_mate/screens/attendance_screen.dart';
import 'package:study_mate/screens/add_schedule_screen.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page Header
                  Text('Academics', style: theme.textTheme.headlineLarge),
                  Text(
                    'Manage your courses, schedule, and academic progress.',
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),

                  // Semester Overview (Hero Card)
                  _buildSemesterOverview(context),
                  const SizedBox(height: 24),

                  // Bento Grid Layout for Academic Modules
                  _buildMobileBentoGrid(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterOverview(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.primaryFixed.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Academic Standing', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        const Text(
                          'Live calculation from your records',
                          style: TextStyle(color: AppTheme.tertiary, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Consumer<AttendanceProvider>(
                    builder: (context, att, _) {
                      int totalPresent = 0;
                      int totalClasses = 0;
                      att.stats.forEach((cid, stat) {
                        totalPresent += stat['present'] ?? 0;
                        totalClasses += stat['total'] ?? 0;
                      });
                      final p = totalClasses == 0 ? 0 : (totalPresent / totalClasses);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${(p * 100).toInt()}%', style: theme.textTheme.displaySmall?.copyWith(color: AppTheme.primary)),
                          const Text('AVG ATTENDANCE', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<AttendanceProvider>(
                builder: (context, att, _) {
                  int totalPresent = 0;
                  int totalClasses = 0;
                  att.stats.forEach((cid, stat) {
                    totalPresent += stat['present'] ?? 0;
                    totalClasses += stat['total'] ?? 0;
                  });
                  final p = totalClasses == 0 ? 0.0 : (totalPresent / totalClasses);
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: p,
                      minHeight: 8,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileBentoGrid(BuildContext context) {
    return Column(
      children: [
        _buildCoursesCard(context),
        const SizedBox(height: 16),
        _buildUpNextCard(context),
        const SizedBox(height: 16),
        _buildAssignmentsMiniCard(context),
        const SizedBox(height: 16),
        _buildExamsCard(context),
        const SizedBox(height: 16),
        _buildAttendanceCard(context),
      ],
    );
  }

  Widget _buildCoursesCard(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final courses = courseProvider.courses;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const MyCoursesScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: AppTheme.primaryContainer, shape: BoxShape.circle),
                      child: const Icon(Icons.book, size: 16, color: AppTheme.primary),
                    ),
                    const SizedBox(width: 12),
                    const Text('Current Courses', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Icon(Icons.arrow_forward, color: AppTheme.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: 20),
            if (courseProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (courses.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text('No courses added yet', style: TextStyle(color: AppTheme.onSurfaceVariant))))
            else
              ...courses.take(3).map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: _buildCourseItem(c.name, c.code, '${c.creditHours} CR'),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseItem(String name, String code, String grade) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(code, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFD6E4F9), borderRadius: BorderRadius.circular(20)),
            child: Text(grade, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextCard(BuildContext context) {
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final today = DateFormat('EEEE').format(DateTime.now());
    final todaysClasses = scheduleProvider.getSchedulesForDay(today);
    
    // Find next class today
    Schedule? nextClass;
    final nowTime = DateTime.now();
    final nowMinutes = nowTime.hour * 60 + nowTime.minute;

    for (var s in todaysClasses) {
      final startMinutes = s.startTime.hour * 60 + s.startTime.minute;
      if (startMinutes > nowMinutes) {
        if (nextClass == null) {
          nextClass = s;
        } else {
          final nextStartMinutes = nextClass.startTime.hour * 60 + nextClass.startTime.minute;
          if (startMinutes < nextStartMinutes) {
            nextClass = s;
          }
        }
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TimetableScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Up Next', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen()));
                  },
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  tooltip: 'Schedule Class',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (nextClass != null) ...[
              Text('TODAY, ${nextClass.startTime.format(context)}', style: const TextStyle(color: AppTheme.primaryFixed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Text(nextClass.courseName ?? 'Untitled Course', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppTheme.primaryFixed),
                  const SizedBox(width: 4),
                  Text(nextClass.room ?? 'TBA', style: const TextStyle(color: AppTheme.primaryFixed, fontSize: 14)),
                ],
              ),
            ] else ...[
              const Text('No more classes today', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Take some time to study!', style: TextStyle(color: AppTheme.primaryFixed, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsMiniCard(BuildContext context) {
    final theme = Theme.of(context);
    final assignments = Provider.of<AssignmentProvider>(context).assignments;
    final pendingCount = assignments.where((a) => a.status == AssignmentStatus.pending).length;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.secondaryContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppTheme.secondaryContainer.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Assignments', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.assignment, color: AppTheme.secondary),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('$pendingCount', style: theme.textTheme.displayLarge?.copyWith(color: AppTheme.secondary, height: 1)),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text('Pending Tasks', style: TextStyle(color: Colors.white70, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('View all tasks →', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildExamsCard(BuildContext context) {
    final theme = Theme.of(context);
    final exams = Provider.of<ExamProvider>(context).exams;
    final upcomingExams = exams.where((e) => e.dateTime.isAfter(DateTime.now())).toList();
    upcomingExams.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    
    Exam? nextExam = upcomingExams.isNotEmpty ? upcomingExams.first : null;
    int diff = nextExam != null ? nextExam.dateTime.difference(DateTime.now()).inDays : 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ExamsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
          border: Border.all(color: AppTheme.error.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Exams', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.quiz, color: AppTheme.error),
              ],
            ),
            const SizedBox(height: 24),
            if (nextExam != null) ...[
              const Text('Next exam in', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('$diff', style: theme.textTheme.displayLarge?.copyWith(color: AppTheme.error, height: 1)),
                  const SizedBox(width: 4),
                  const Text('days', style: TextStyle(color: AppTheme.error, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(nextExam.title, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(DateFormat('MMM d').format(nextExam.dateTime), style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
                ],
              ),
            ] else ...[
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Text('No upcoming exams', style: TextStyle(color: AppTheme.onSurfaceVariant)))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    final attProvider = Provider.of<AttendanceProvider>(context);
    int totalPresent = 0;
    int totalClasses = 0;
    attProvider.stats.forEach((cid, stat) {
      totalPresent += stat['present'] ?? 0;
      totalClasses += stat['total'] ?? 0;
    });
    final p = totalClasses == 0 ? 0.0 : (totalPresent / totalClasses);

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFD6E4F9).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E4F9)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.fact_check, size: 16, color: AppTheme.tertiary),
                    SizedBox(width: 8),
                    Text('Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Overall average', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
              ],
            ),
            SizedBox(
              width: 64,
              height: 64,
              child: Stack(
                children: [
                  Center(
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(
                        value: p,
                        strokeWidth: 6,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(p * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
