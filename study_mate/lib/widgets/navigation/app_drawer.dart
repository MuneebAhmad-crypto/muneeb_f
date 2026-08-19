import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    
    final userName = profile?['name'] ?? 'User';
    final university = profile?['university'] ?? 'Student';
    final gpa = profile?['gpa']?.toString() ?? '0.0';

    return Container(
      width: 280,
      color: AppTheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.surfaceVariant,
                        backgroundImage: (profile?['avatar_url'] != null && profile!['avatar_url'].toString().isNotEmpty)
                          ? NetworkImage(profile['avatar_url']) 
                          : null,
                        child: (profile?['avatar_url'] == null || profile!['avatar_url'].toString().isEmpty)
                          ? const Icon(Icons.person, color: AppTheme.primary) 
                          : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(university, style: const TextStyle(fontSize: 12, color: AppTheme.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('GPA: $gpa', style: const TextStyle(fontSize: 10, color: AppTheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Nav Items
                  _buildDrawerItem(Icons.home_outlined, 'Home', selectedIndex == 0, () => onDestinationSelected(0)),
                  _buildDrawerItem(Icons.school_outlined, 'Academics', selectedIndex == 1, () => onDestinationSelected(1)),
                  _buildDrawerItem(Icons.menu_book_outlined, 'Study', selectedIndex == 2, () => onDestinationSelected(2)),
                  _buildDrawerItem(Icons.calculate_outlined, 'Tools', selectedIndex == 3, () => onDestinationSelected(3)),
                  _buildDrawerItem(Icons.person_outline, 'Profile', selectedIndex == 4, () => onDestinationSelected(4)),
                ],
              ),
            ),
          ),
          const Divider(),
          _buildDrawerItem(Icons.settings_outlined, 'Settings', false, () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : AppTheme.onSurfaceVariant),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: onTap,
      ),
    );
  }
}
