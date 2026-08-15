import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/auth_provider.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/screens/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    final userName = profile?['name'] ?? 'Alex Johnson';
    final userEmail = profile?['email'] ?? 'alex.johnson@university.edu';
    final university = profile?['university'] ?? 'Computer Science';
    final semester = profile?['semester']?.toString() ?? 'Year 3';
    final avatarUrl = profile?['avatar_url'] ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBeWr1BC4szls-8tSaOIk8VEiBdc40gjFM1xkc3xRcKSTUfZCBpNCAGCOVUFQt0z2syj0Rg3bOD7fc9Y4a7qiovHtC8UmhUigpzsJCxq49N57e2U1VEz897cau3NOYuvi7O-IAqr-xu7zoJF1x-h3KbVgEI4fmFtBxakwX7n85EJhkAiRiqpp8bAAOpEU_dvN8vJf6q8z0bCIkQjj1ngmS566dh9ZNrkPubJ67Lm6LKC9JZDx6hkiKioQ';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('StudyMate', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person, color: AppTheme.primary),
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
                // Profile Header
                _buildProfileHeader(theme, isDesktop, userName, userEmail, university, semester, avatarUrl),
                const SizedBox(height: 32),

                // Settings Sections
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _buildSettingsSection(
                              title: 'Account',
                              items: [
                                _buildSettingsItem(Icons.edit, 'Edit Profile Info', 'Update your personal details'),
                                _buildSettingsItem(Icons.lock, 'Change Password', 'Ensure your account is secure'),
                              ],
                            ),
                            const SizedBox(height: 24),
                            _buildSettingsSection(
                              title: 'Academic',
                              items: [
                                _buildSettingsItem(Icons.school, 'University Details', 'View enrolled courses & GPA'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            _buildPreferencesSection(theme),
                            const SizedBox(height: 24),
                            _buildSettingsSection(
                              title: 'Other',
                              items: [
                                _buildSettingsItem(Icons.info, 'About StudyMate', 'Version 1.2.0'),
                                _buildSettingsItem(
                                  Icons.logout,
                                  'Logout',
                                  null,
                                  isDestructive: true,
                                  onTap: () => _handleLogout(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    children: [
                      _buildSettingsSection(
                        title: 'Account',
                        items: [
                          _buildSettingsItem(Icons.edit, 'Edit Profile Info', 'Update your personal details'),
                          _buildSettingsItem(Icons.lock, 'Change Password', 'Ensure your account is secure'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildPreferencesSection(theme),
                      const SizedBox(height: 24),
                      _buildSettingsSection(
                        title: 'Academic',
                        items: [
                          _buildSettingsItem(Icons.school, 'University Details', 'View enrolled courses & GPA'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildSettingsSection(
                        title: 'Other',
                        items: [
                          _buildSettingsItem(Icons.info, 'About StudyMate', 'Version 1.2.0'),
                          _buildSettingsItem(Icons.logout, 'Logout', null, isDestructive: true),
                        ],
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

  Widget _buildProfileHeader(ThemeData theme, bool isDesktop, String name, String email, String university, String semester, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.headlineLarge),
                Text(email, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTag(university, AppTheme.primaryFixed, AppTheme.onPrimaryFixed),
                    _buildTag(semester, AppTheme.secondaryFixed, AppTheme.onSecondaryFixed),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.primary,
                minimumSize: const Size(120, 40),
                side: BorderSide(color: AppTheme.outlineVariant.withOpacity(0.5)),
              ),
              child: const Text('Edit Profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildSettingsSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: AppTheme.outlineVariant.withOpacity(0.3)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String? subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? AppTheme.errorContainer.withOpacity(0.3) : AppTheme.surfaceVariant.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.tertiary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? AppTheme.error : AppTheme.onSurface)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: AppTheme.outline),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildPreferencesSection(ThemeData theme) {
    return _buildSettingsSection(
      title: 'Preferences',
      items: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dark_mode, color: AppTheme.tertiary, size: 20),
          ),
          title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: Switch(
            value: false,
            onChanged: (val) {},
            activeColor: AppTheme.primary,
          ),
        ),
        const Divider(height: 1),
        _buildSettingsItem(Icons.notifications, 'Notifications', 'Manage alerts and emails'),
      ],
    );
  }
}
