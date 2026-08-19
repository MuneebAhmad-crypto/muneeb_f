import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';

class UniversityDetailsScreen extends StatelessWidget {
  const UniversityDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<ProfileProvider>(context).profile;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('University Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildDetailCard(Icons.account_balance, 'University', profile?['university'] ?? 'Not specified'),
            const SizedBox(height: 16),
            _buildDetailCard(Icons.badge, 'Registration ID', profile?['reg_number'] ?? 'Not specified'),
            const SizedBox(height: 16),
            _buildDetailCard(Icons.school, 'Program', profile?['program'] ?? 'BS Software Engineering'),
            const SizedBox(height: 16),
            _buildDetailCard(Icons.calendar_today, 'Current Semester', profile?['semester']?.toString() ?? '1'),
            const SizedBox(height: 16),
            _buildDetailCard(Icons.analytics, 'Current GPA', profile?['gpa']?.toString() ?? '0.0'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.primaryContainer.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
