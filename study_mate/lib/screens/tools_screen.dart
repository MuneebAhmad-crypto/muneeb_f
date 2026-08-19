import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/screens/gpa_calculator_screen.dart';
import 'package:study_mate/screens/attendance_calculator_screen.dart';
import 'package:study_mate/screens/cgpa_calculator_screen.dart';
import 'package:study_mate/screens/percentage_calculator_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('StudyMate', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuA2kyVoIE-qyqgyVdSoZhHJLpHU5QUCekacW6LslDeKEJW40ZJF5-dHtTqh0mEHdzzixsc4RONs6bG9N_TsqlD1QdAHBvSgDAGaYnuynxe3ky3Bs2uRJY_TK-0jEx_TwID8DFPCqec7Yu1jXpG6LGeUWJD-vdlRNMvgF6BEV8sEEe3C9QSIHoXzKJfilAkd9GB7VBXlKgePO49bij6sTomqmC97SLy3NerovdWA8jFP0Ihx1hI9abSuaA'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Text('Tools', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 8),
                Text(
                  'Essential calculators for your academic planning.',
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // Tools Grid
                GridView.count(
                  crossAxisCount: 1,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 24,
                  childAspectRatio: 1.3,
                  children: [
                    _buildToolCard(
                      icon: Icons.calculate,
                      iconColor: AppTheme.primary,
                      iconBgColor: AppTheme.primaryContainer,
                      title: 'GPA Calculator',
                      description: 'Estimate your semester Grade Point Average based on your current credit hours and expected grades.',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const GpaCalculatorScreen()));
                      },
                    ),
                    _buildToolCard(
                      icon: Icons.school,
                      iconColor: AppTheme.tertiary,
                      iconBgColor: AppTheme.tertiaryFixedDim,
                      title: 'CGPA Calculator',
                      description: 'Track your Cumulative Grade Point Average across multiple semesters to monitor long-term progress.',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CgpaCalculatorScreen()));
                      },
                    ),
                    _buildToolCard(
                      icon: Icons.fact_check,
                      iconColor: AppTheme.secondary,
                      iconBgColor: AppTheme.secondaryFixed,
                      title: 'Attendance Calculator',
                      description: 'Find out how many classes you can afford to miss while maintaining your target attendance percentage.',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AttendanceCalculatorScreen()));
                      },
                    ),
                    _buildToolCard(
                      icon: Icons.percent,
                      iconColor: AppTheme.onSurface,
                      iconBgColor: AppTheme.surfaceVariant,
                      title: 'Percentage Calculator',
                      description: 'Quickly convert marks to percentages or calculate weighted scores for complex assignments.',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const PercentageCalculatorScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.background,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_forward, size: 18, color: AppTheme.outline),
                ),
              ],
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
