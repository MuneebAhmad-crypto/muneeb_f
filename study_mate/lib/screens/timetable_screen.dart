import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/models/schedule.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  int _selectedDayIndex = 0;
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final selectedDay = _days[_selectedDayIndex];
    final daySchedules = scheduleProvider.getSchedulesForDay(selectedDay);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Header & Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Weekly Schedule', style: theme.textTheme.headlineLarge?.copyWith(color: AppTheme.primary)),
                        const Row(
                          children: [
                            Icon(Icons.event, size: 16, color: AppTheme.onSurfaceVariant),
                            SizedBox(width: 8),
                            Text('University Timetable', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Class'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Days Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_days.length, (index) {
                      final isSelected = _selectedDayIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(_days[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                          backgroundColor: AppTheme.surface,
                          shape: const StadiumBorder(),
                          side: isSelected ? BorderSide.none : const BorderSide(color: AppTheme.outlineVariant),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 24),

                // Interactive Timeline Container
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
                    ],
                    border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.5)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 800),
                      child: Stack(
                        children: [
                          // Time Axis and Grid Lines
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTimeAxis(),
                              Expanded(
                                child: _buildGridLines(),
                              ),
                            ],
                          ),
                          // Class Cards
                          Positioned(
                            top: 16,
                            left: 60,
                            right: 0,
                            bottom: 0,
                            child: Stack(
                              children: [
                                ...daySchedules.map((s) => _buildClassCardFromSchedule(context, s)),
                                // Current Time Indicator
                                Positioned(
                                  top: 180, // Example current time 10:15
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(color: AppTheme.secondary, shape: BoxShape.circle),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 2,
                                          color: AppTheme.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeAxis() {
    return Container(
      width: 60,
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.3))),
      ),
      child: Column(
        children: List.generate(10, (index) {
          final hour = 8 + index;
          return Container(
            height: 80,
            alignment: Alignment.topRight,
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${hour.toString().padLeft(2, '0')}:00',
              style: const TextStyle(fontSize: 12, color: AppTheme.outline),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGridLines() {
    return Column(
      children: List.generate(10, (index) {
        return Container(
          height: 80,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.2), style: BorderStyle.solid)),
          ),
        );
      }),
    );
  }

  Widget _buildClassCardFromSchedule(BuildContext context, Schedule s) {
    // 8am is 0px, 9am is 80px, etc.
    final top = (s.startTime.hour - 8) * 80.0 + (s.startTime.minute / 60.0) * 80.0;
    final durationInMinutes = (s.endTime.hour * 60 + s.endTime.minute) - (s.startTime.hour * 60 + s.startTime.minute);
    final height = (durationInMinutes / 60.0) * 80.0;

    return _buildClassCard(
      context: context,
      top: top,
      height: height,
      left: 16, // simplifying overlapping logic for now
      right: 16,
      color: AppTheme.primary,
      containerColor: AppTheme.primaryContainer,
      courseCode: s.courseCode ?? 'N/A',
      title: s.courseName ?? 'Untitled',
      time: '${s.startTime.format(context)} - ${s.endTime.format(context)}',
      location: s.room ?? 'TBA',
    );
  }

  Widget _buildClassCard({
    required BuildContext context,
    required double top,
    required double height,
    required double left,
    required double right,
    required Color color,
    required Color containerColor,
    required String courseCode,
    required String title,
    required String time,
    required String location,
  }) {
    return Positioned(
      top: top,
      height: height,
      left: left,
      right: right,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 6)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), borderRadius: BorderRadius.circular(6)),
                  child: Text(courseCode, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                Icon(Icons.edit, size: 14, color: color.withOpacity(0.6)),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            if (height > 60) ...[
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.schedule, size: 12, color: color.withOpacity(0.8)),
                  const SizedBox(width: 4),
                  Text(time, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.location_on, size: 12, color: color.withOpacity(0.8)),
                  const SizedBox(width: 4),
                  Text(location, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
