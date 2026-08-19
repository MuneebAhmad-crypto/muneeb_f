import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/screens/add_schedule_screen.dart';
import 'package:intl/intl.dart';

class TodaysClassesScreen extends StatelessWidget {
  const TodaysClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final today = DateFormat('EEEE', 'en_US').format(DateTime.now());
    final todaysClasses = scheduleProvider.getSchedulesForDay(today);

    // Sort classes by time
    todaysClasses.sort((a, b) {
      final aMin = a.startTime.hour * 60 + a.startTime.minute;
      final bMin = b.startTime.hour * 60 + b.startTime.minute;
      return aMin.compareTo(bMin);
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Today\'s Classes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: todaysClasses.isEmpty
          ? _buildEmptyState(theme, context)
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: todaysClasses.length,
              itemBuilder: (context, index) {
                return _buildClassCard(context, todaysClasses[index]);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen()));
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Schedule Class'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 80, color: AppTheme.outlineVariant),
          const SizedBox(height: 16),
          const Text('No classes today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Take some time to rest or catch up!', style: TextStyle(color: AppTheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddScheduleScreen()));
            },
            child: const Text('Add to Timetable'),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, Schedule s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 6,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppTheme.primaryContainer, borderRadius: BorderRadius.circular(8)),
                          child: Text(s.courseCode ?? 'N/A', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        Text(
                          '${s.startTime.format(context)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.onSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(s.courseName ?? 'Untitled Course', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Room: ${s.room ?? 'TBA'}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 18, color: AppTheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Duration: ${s.startTime.format(context)} - ${s.endTime.format(context)}', style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
