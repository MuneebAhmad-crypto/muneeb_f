import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/providers/assignment_provider.dart';
import 'package:study_mate/providers/attendance_provider.dart';
import 'package:study_mate/providers/exam_provider.dart';
import 'package:study_mate/providers/task_provider.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/screens/note_editor_screen.dart';
import 'package:intl/intl.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/models/exam.dart';
import 'package:study_mate/screens/timetable_screen.dart';
import 'package:study_mate/screens/assignments_screen.dart';
import 'package:study_mate/screens/exams_screen.dart';
import 'package:study_mate/screens/attendance_screen.dart';
import 'package:study_mate/screens/profile_screen.dart';
import 'package:study_mate/screens/todays_classes_screen.dart';
import 'package:study_mate/screens/add_schedule_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _showAddTaskDialog(BuildContext context) {
    final controller = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'What needs to be done?'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (controller.text.isNotEmpty) {
                  setDialogState(() => isSaving = true);
                  await Provider.of<TaskProvider>(context, listen: false).addTask(controller.text.trim());
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                : const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Image.asset('asset/logo.png', height: 32, errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, color: AppTheme.primary)),
              const SizedBox(width: 8),
              const Text('StudyMate', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () => _showNotificationsModal(context),
            icon: const Icon(Icons.notifications_none, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Consumer<ProfileProvider>(
            builder: (context, profileProv, _) {
              final avatarUrl = profileProv.profile?['avatar_url'];
              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.surfaceVariant,
                    backgroundImage: (avatarUrl != null && avatarUrl.toString().isNotEmpty)
                      ? NetworkImage(avatarUrl) 
                      : null,
                    child: (avatarUrl == null || avatarUrl.toString().isEmpty)
                      ? const Icon(Icons.person, size: 16, color: AppTheme.primary) 
                      : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final courses = Provider.of<CourseProvider>(context, listen: false);
          final schedules = Provider.of<ScheduleProvider>(context, listen: false);
          final assignments = Provider.of<AssignmentProvider>(context, listen: false);
          final exams = Provider.of<ExamProvider>(context, listen: false);
          final att = Provider.of<AttendanceProvider>(context, listen: false);

          await courses.fetchCourses();
          await schedules.fetchSchedules();
          await assignments.fetchAssignments();
          await exams.fetchExams();
          await att.fetchAttendance();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<ProfileProvider>(
                      builder: (context, profileProv, _) => Text(
                        'Good morning, ${profileProv.profile?['name'] ?? 'Student'} 👋', 
                        style: theme.textTheme.headlineLarge
                      ),
                    ),
                    Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant)),
                    const SizedBox(height: 24),
                    
                    // Overview Grid
                    Consumer5<ScheduleProvider, AssignmentProvider, ExamProvider, AttendanceProvider, CourseProvider>(
                      builder: (context, scheduleProv, assignProv, examProv, attProv, courseProv, _) {
                        final today = DateFormat('EEEE', 'en_US').format(DateTime.now());
                        final todaysClasses = scheduleProv.getSchedulesForDay(today);
                        final pendingAssignments = assignProv.assignments.where((a) => a.status == AssignmentStatus.pending).toList();
                        final upcomingExams = examProv.exams.where((e) => e.dateTime.isAfter(DateTime.now())).toList();
                        
                        int totalPresent = 0;
                        int totalClasses = 0;
                        attProv.stats.forEach((cid, stat) {
                          totalPresent += stat['present'] ?? 0;
                          totalClasses += stat['total'] ?? 0;
                        });
                        final overallAttendance = totalClasses == 0 ? 0.0 : (totalPresent / totalClasses) * 100;

                        return Column(
                          children: [
                            GridView.count(
                              crossAxisCount: MediaQuery.of(context).size.width >= 768 ? 4 : 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                              children: [
                                _buildOverviewCard(
                                  icon: Icons.menu_book,
                                  color: AppTheme.primary,
                                  value: todaysClasses.length.toString(),
                                  label: 'Classes Today',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const TodaysClassesScreen())),
                                ),
                                _buildOverviewCard(
                                  icon: Icons.assignment,
                                  color: AppTheme.secondaryContainer,
                                  value: pendingAssignments.length.toString(),
                                  label: 'Due Soon',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentsScreen())),
                                ),
                                _buildOverviewCard(
                                  icon: Icons.quiz,
                                  color: AppTheme.error,
                                  value: upcomingExams.length.toString(),
                                  label: 'Upcoming Exam',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ExamsScreen())),
                                ),
                                _buildOverviewCard(
                                  icon: Icons.fact_check,
                                  color: const Color(0xFF14B8A6),
                                  value: '${overallAttendance.toInt()}%',
                                  label: 'Attendance',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen())),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildTodaySchedule(context, todaysClasses),
                            const SizedBox(height: 24),
                            _buildUpcomingAssignment(context, pendingAssignments),
                            const SizedBox(height: 24),
                            _buildUpcomingExam(context, upcomingExams),
                            const SizedBox(height: 24),
                            _buildAttendanceOverview(context, courseProv.courses, attProv.stats),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildQuickActions(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({required IconData icon, required Color color, required String value, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.onSurface)),
              ],
            ),
            Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context, List<Schedule> todaysClasses) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Schedule", style: theme.textTheme.displaySmall),
          const SizedBox(height: 24),
          if (todaysClasses.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: Text('No classes scheduled for today', style: TextStyle(color: AppTheme.onSurfaceVariant))))
          else
            ...todaysClasses.map((s) => _buildScheduleItem(
                  context,
                  time: '${s.startTime.hour.toString().padLeft(2, '0')}:${s.startTime.minute.toString().padLeft(2, '0')}',
                  title: s.courseName ?? 'Untitled Course',
                  code: s.courseCode ?? 'N/A',
                  duration: '${s.startTime.format(context)} - ${s.endTime.format(context)}',
                  location: s.room ?? 'TBA',
                  isActive: true,
                )),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(BuildContext context, {required String time, required String title, required String code, required String duration, required String location, required bool isActive}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceVariant, shape: BoxShape.circle, border: Border.all(color: AppTheme.surface, width: 4)),
                child: Center(child: Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
              ),
              Expanded(child: Container(width: 2, color: AppTheme.surfaceVariant)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.surfaceVariant), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFD6E4F9), borderRadius: BorderRadius.circular(4)), child: Text(code, style: const TextStyle(fontSize: 12, color: Color(0xFF3A4859)))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.schedule, size: 16, color: AppTheme.onSurfaceVariant), const SizedBox(width: 4), Text(duration, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant))]),
                        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant), const SizedBox(width: 4), Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant))]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAssignment(BuildContext context, List<Assignment> assignments) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppTheme.secondaryContainer),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFFFDBCC), borderRadius: BorderRadius.circular(4)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.warning, size: 14, color: Color(0xFF7A3000)), const SizedBox(width: 4), Text(assignments.isEmpty ? "No Pending Work" : "Due Soon", style: const TextStyle(fontSize: 12, color: Color(0xFF7A3000)))])),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(assignments.isEmpty ? "Enjoy your free time!" : assignments.first.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(assignments.isEmpty ? "All caught up with assignments." : (assignments.first.courseName ?? 'General'), style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                    if (assignments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignmentsScreen())), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.surfaceVariant, foregroundColor: AppTheme.onSurface, elevation: 0), child: const Text("Submit Work")),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingExam(BuildContext context, List<Exam> exams) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: AppTheme.error),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.errorContainer, borderRadius: BorderRadius.circular(4)), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.event, size: 14, color: AppTheme.onErrorContainer), const SizedBox(width: 4), Text(exams.isEmpty ? "No Upcoming Exams" : DateFormat('MMM d, h:mm a').format(exams.first.dateTime), style: const TextStyle(fontSize: 12, color: AppTheme.onErrorContainer))])),
                    const SizedBox(height: 12),
                    Text(exams.isEmpty ? "Stay prepared" : exams.first.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(exams.isEmpty ? "No exams scheduled soon." : (exams.first.courseName ?? 'General'), style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
                    if (exams.isNotEmpty && exams.first.room != null) ...[
                      const SizedBox(height: 16),
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.surfaceVariant)), child: Row(children: [const Icon(Icons.location_on, size: 18, color: AppTheme.onSurfaceVariant), const SizedBox(width: 8), Text(exams.first.room!, style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant))])),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOverview(BuildContext context, List courses, Map stats) {
    final theme = Theme.of(context);
    final topCourses = courses.take(2).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Attendance Overview", style: theme.textTheme.displaySmall), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceScreen())), child: const Text("View All"))]),
          const SizedBox(height: 16),
          if (topCourses.isEmpty)
            const Center(child: Text('No courses found', style: TextStyle(color: AppTheme.onSurfaceVariant)))
          else
            ...topCourses.map((c) {
              final s = stats[c.id] ?? {'present': 0, 'total': 0};
              final p = (s['total'] as int? ?? 0) == 0 ? 0.0 : ((s['present'] as int? ?? 0) / (s['total'] as int? ?? 1));
              return Padding(padding: const EdgeInsets.only(bottom: 12.0), child: _buildAttendanceProgress(c.name, p, AppTheme.primary));
            }),
        ],
      ),
    );
  }

  Widget _buildAttendanceProgress(String title, double percentage, Color color) {
    return Column(
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 14, color: AppTheme.onSurface)), Text("${(percentage * 100).toInt()}%", style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant))]),
        const SizedBox(height: 8),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: percentage, backgroundColor: AppTheme.surfaceVariant, valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildQuickActionButton(icon: Icons.add_task, color: AppTheme.primary, label: "Add Task", onTap: () => _showAddTaskDialog(context))),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickActionButton(icon: Icons.calendar_month, color: AppTheme.secondary, label: "Schedule", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen())))),
              const SizedBox(width: 12),
              Expanded(child: _buildQuickActionButton(icon: Icons.note_add, color: AppTheme.secondaryContainer, label: "New Note", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NoteEditorScreen())))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.outlineVariant)), child: Column(children: [Icon(icon, color: color), const SizedBox(height: 8), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))])));
  }

  void _showNotificationsModal(BuildContext context) {
    final assignProv = Provider.of<AssignmentProvider>(context, listen: false);
    final examProv = Provider.of<ExamProvider>(context, listen: false);
    final pendingAssignments = assignProv.assignments.where((a) => a.status == AssignmentStatus.pending).toList();
    final upcomingExams = examProv.exams.where((e) => e.dateTime.isAfter(DateTime.now())).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            if (pendingAssignments.isEmpty && upcomingExams.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0),
                child: Center(child: Text('🎉 All caught up! No urgent alerts.', style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceVariant))),
              )
            else ...[
              if (pendingAssignments.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.assignment, color: AppTheme.secondaryContainer),
                  title: Text('${pendingAssignments.length} Assignments Due'),
                  subtitle: Text('Next due: ${pendingAssignments.first.title}'),
                ),
              ],
              if (upcomingExams.isNotEmpty) ...[
                ListTile(
                  leading: const Icon(Icons.quiz, color: AppTheme.error),
                  title: Text('${upcomingExams.length} Upcoming Exams'),
                  subtitle: Text('Next exam: ${upcomingExams.first.title}'),
                ),
              ],
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
