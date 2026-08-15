import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:intl/intl.dart';
import 'package:study_mate/models/schedule.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    
    final userName = profileProvider.profile?['name'] ?? 'Student';
    final avatarUrl = profileProvider.profile?['avatar_url'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuAMv2as2RPsZq-KEEqVJvSkHmCk4jSEDahNs9FU_CEktPJjyUf557HEVkA5APqy6v2T_LJf9HQyeT-guN09lsWCws0LGXpENaLffFlNLRZyj2AEusuhjoZrCfrHF-6IdlGjtsGwW5loXO1DlVmXUQjwt0Ig2HFHcaPTfmljs7ipIv_gTthBeyT7frr5MkwuvUmz1ZgrRfKDBC3u6G32Z42zvX3gIidw1umB39FQGCFP5MobnA2n-rZFBg';
    
    final today = DateFormat('EEEE').format(DateTime.now());
    final todaysClasses = scheduleProvider.getSchedulesForDay(today);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: isDesktop 
          ? const Text('StudyMate', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold))
          : const SizedBox.shrink(),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none, color: AppTheme.onSurfaceVariant),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(avatarUrl),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text(
                  'Good morning, $userName 👋',
                  style: theme.textTheme.headlineLarge,
                ),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Grid: Today's Overview
                GridView.count(
                  crossAxisCount: isDesktop ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: isDesktop ? 1.5 : 1.3,
                  children: [
                    _buildOverviewCard(
                      icon: Icons.menu_book,
                      color: AppTheme.primary,
                      value: todaysClasses.length.toString(),
                      label: 'Classes Today',
                    ),
                    _buildOverviewCard(
                      icon: Icons.assignment,
                      color: AppTheme.secondaryContainer,
                      value: '0',
                      label: 'Due Soon',
                    ),
                    _buildOverviewCard(
                      icon: Icons.quiz,
                      color: AppTheme.error,
                      value: '0',
                      label: 'Upcoming Exam',
                    ),
                    _buildOverviewCard(
                      icon: Icons.fact_check,
                      color: const Color(0xFF14B8A6),
                      value: '0%',
                      label: 'Overall Attendance',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Main Content Area
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildTodaySchedule(context, todaysClasses),
                            const SizedBox(height: 24),
                            _buildAttendanceOverview(theme),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildUpcomingAssignment(theme),
                            const SizedBox(height: 24),
                            _buildUpcomingExam(theme),
                            const SizedBox(height: 24),
                            _buildQuickActions(theme),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildTodaySchedule(context, todaysClasses),
                      const SizedBox(height: 24),
                      _buildUpcomingAssignment(theme),
                      const SizedBox(height: 24),
                      _buildUpcomingExam(theme),
                      const SizedBox(height: 24),
                      _buildAttendanceOverview(theme),
                      const SizedBox(height: 24),
                      _buildQuickActions(theme),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(BuildContext context, List<Schedule> todaysClasses) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Schedule", style: theme.textTheme.displaySmall),
          const SizedBox(height: 24),
          if (todaysClasses.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0),
                child: Text('No classes scheduled for today', style: TextStyle(color: AppTheme.onSurfaceVariant)),
              ),
            )
          else
            ...todaysClasses.map((s) => _buildScheduleItem(
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

  Widget _buildScheduleItem({
    required String time,
    required String title,
    required String code,
    required String duration,
    required String location,
    required bool isActive,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primaryContainer : AppTheme.surfaceVariant,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.surface, width: 4),
                ),
                child: Center(
                  child: Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? AppTheme.onPrimaryContainer : AppTheme.onSurface,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: AppTheme.surfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD6E4F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(code, style: const TextStyle(fontSize: 12, color: Color(0xFF3A4859))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(duration, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                        const SizedBox(width: 16),
                        const Icon(Icons.location_on, size: 16, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(location, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
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

  Widget _buildAttendanceOverview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attendance Overview", style: theme.textTheme.displaySmall),
              TextButton(onPressed: () {}, child: const Text("View All")),
            ],
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text('No attendance records found', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAssignment(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: AppTheme.secondaryContainer, width: 4),
          top: BorderSide(color: Colors.white.withOpacity(0.5)),
          right: BorderSide(color: Colors.white.withOpacity(0.5)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBCC),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, size: 14, color: Color(0xFF7A3000)),
                    SizedBox(width: 4),
                    Text("No Pending Work", style: TextStyle(fontSize: 12, color: Color(0xFF7A3000))),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: AppTheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Enjoy your free time!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("All caught up with assignments.", style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildUpcomingExam(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: const BorderSide(color: AppTheme.error, width: 4),
          top: BorderSide(color: Colors.white.withOpacity(0.5)),
          right: BorderSide(color: Colors.white.withOpacity(0.5)),
          bottom: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.errorContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.event, size: 14, color: AppTheme.onErrorContainer),
                SizedBox(width: 4),
                Text("No Upcoming Exams", style: TextStyle(fontSize: 12, color: AppTheme.onErrorContainer)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text("Stay prepared", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Text("No exams scheduled soon.", style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(Icons.add_task, AppTheme.primary, "Add Task"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionButton(Icons.note_add, AppTheme.secondaryContainer, "New Note"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
