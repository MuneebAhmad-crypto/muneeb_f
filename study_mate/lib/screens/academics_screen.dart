import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/screens/timetable_screen.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    // final isDesktop = size.width >= 768;

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
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 900) {
                      return _buildDesktopBentoGrid(context);
                    } else {
                      return _buildMobileBentoGrid(context);
                    }
                  },
                ),
              ],
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
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
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
                color: AppTheme.primaryFixed.withOpacity(0.3),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spring 2024 Semester', style: theme.textTheme.displaySmall),
                      const Text(
                        'Week 8 of 15 • Midterms Approaching',
                        style: TextStyle(color: AppTheme.tertiary, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('53%', style: theme.textTheme.displaySmall?.copyWith(color: AppTheme.primary)),
                      const Text('COMPLETED', style: TextStyle(fontSize: 10, letterSpacing: 1.2, fontWeight: FontWeight.bold, color: AppTheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: const LinearProgressIndicator(
                  value: 0.53,
                  minHeight: 8,
                  backgroundColor: AppTheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopBentoGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildCoursesCard(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildUpNextCard(context),
                  const SizedBox(height: 24),
                  _buildAssignmentsMiniCard(context),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildExamsCard(context),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildAttendanceCard(context),
            ),
          ],
        ),
      ],
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.2)),
      ),
      child: Column(
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
          _buildCourseItem('Data Structures & Algorithms', 'CS 301 • 4 Credits', 'A-'),
          const SizedBox(height: 12),
          _buildCourseItem('Modern World History', 'HIST 205 • 3 Credits', 'B+'),
        ],
      ),
    );
  }

  Widget _buildCourseItem(String name, String details, String grade) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(details, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
            ],
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
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Up Next', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Icon(Icons.calendar_month, color: Colors.white),
              ],
            ),
            const SizedBox(height: 32),
            const Text('TODAY, 2:00 PM', style: TextStyle(color: AppTheme.primaryFixed, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const Text('Software Engineering Lab', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.location_on, size: 16, color: AppTheme.primaryFixed),
                SizedBox(width: 4),
                Text('Room 402, Engineering Bldg', style: TextStyle(color: AppTheme.primaryFixed, fontSize: 14)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentsMiniCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.secondaryContainer.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 4))],
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
              Text('3', style: theme.textTheme.displayLarge?.copyWith(color: AppTheme.secondary, height: 1)),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text('Due this week', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('View all tasks →', style: TextStyle(color: AppTheme.secondary, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildExamsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.error.withOpacity(0.2)),
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
          const Text('Next exam in', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('12', style: theme.textTheme.displayLarge?.copyWith(color: AppTheme.error, height: 1)),
              const SizedBox(width: 4),
              const Text('days', style: TextStyle(color: AppTheme.error, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('CS 301 Midterm', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Oct 24', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E4F9).withOpacity(0.3),
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
                const Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      value: 0.92,
                      strokeWidth: 6,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    '92%',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
