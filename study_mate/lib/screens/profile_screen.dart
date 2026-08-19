import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/auth_provider.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/theme_provider.dart';
import 'package:study_mate/screens/welcome_screen.dart';
import 'package:study_mate/screens/edit_profile_screen.dart';
import 'package:study_mate/screens/university_details_screen.dart';
import 'package:study_mate/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

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

  void _handleResetPassword(BuildContext context, String email) async {
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No valid email found for password reset.')));
      return;
    }
    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset link sent to $email. Please check your inbox.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        String msg = e.toString();
        if (msg.contains('Connection reset') || msg.contains('104')) {
          msg = 'Network Error: Connection reset by peer. This usually happens when your ISP blocks Supabase. \n\nPLEASE TRY:\n1. Switch to Mobile Data\n2. Use a VPN';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppTheme.error, duration: const Duration(seconds: 10)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.profile;
    
    final userName = profile?['name'] ?? 'User';
    final userEmail = profile?['email'] ?? 'student@university.edu';
    final university = profile?['university'] ?? 'University';
    final regNumber = profile?['reg_number'] ?? 'N/A';
    final semester = profile?['semester']?.toString() ?? 'N/A';
    final avatarUrl = profile?['avatar_url'];

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: isDesktop ? null : AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text('StudyMate', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(context, isDesktop, userName, userEmail, university, semester, avatarUrl, regNumber),
                const SizedBox(height: 32),
                
                _buildSettingsSection(
                  context,
                  title: 'Account',
                  items: [
                    _buildSettingsItem(
                      context, 
                      Icons.edit, 
                      'Edit Profile Info', 
                      'Update your personal details', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
                    ),
                    _buildSettingsItem(
                      context, 
                      Icons.lock, 
                      'Change Password', 
                      'Ensure your account is secure', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ChangePasswordScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildPreferencesSection(context),
                const SizedBox(height: 24),
                
                _buildSettingsSection(
                  context,
                  title: 'Academic',
                  items: [
                    _buildSettingsItem(
                      context, 
                      Icons.school, 
                      'University Details', 
                      'View enrolled courses & GPA', 
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UniversityDetailsScreen())),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                _buildSettingsSection(
                  context,
                  title: 'Other',
                  items: [
                    _buildSettingsItem(
                      context, 
                      Icons.info, 
                      'About StudyMate', 
                      'Version 1.2.0', 
                      onTap: () => showAboutDialog(context: context, applicationName: 'StudyMate', applicationVersion: '1.2.0'),
                    ),
                    _buildSettingsItem(
                      context,
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
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDesktop, String name, String email, String university, String semester, String? avatarUrl, String regNumber) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.surfaceVariant,
            backgroundImage: (avatarUrl != null && avatarUrl.toString().isNotEmpty) ? NetworkImage(avatarUrl) : null,
            child: (avatarUrl == null || avatarUrl.toString().isEmpty) ? const Icon(Icons.person, size: 50, color: AppTheme.outline) : null,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.headlineLarge),
                Text(email, style: const TextStyle(color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 12),
                Text('Reg: $regNumber', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.tertiary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(university, AppTheme.primaryFixed, AppTheme.onPrimaryFixed),
                    _buildTag('Semester $semester', AppTheme.secondaryFixed, AppTheme.onSecondaryFixed),
                  ],
                ),
              ],
            ),
          ),
          if (isDesktop)
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surface,
                foregroundColor: AppTheme.primary,
                minimumSize: const Size(120, 40),
                side: BorderSide(color: AppTheme.outlineVariant.withValues(alpha: 0.5)),
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

  Widget _buildSettingsSection(BuildContext context, {required String title, required List<Widget> items}) {
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
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
            ],
            border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.3)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(BuildContext context, IconData icon, String title, String? subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDestructive ? AppTheme.errorContainer.withValues(alpha: 0.3) : AppTheme.surfaceVariant.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isDestructive ? AppTheme.error : AppTheme.tertiary, size: 20),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? AppTheme.error : AppTheme.onSurface)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: AppTheme.outline),
      onTap: onTap,
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return _buildSettingsSection(
      context,
      title: 'Preferences',
      items: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications, color: AppTheme.tertiary, size: 20),
          ),
          title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: const Text('Manage alerts and emails', style: TextStyle(fontSize: 12)),
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (val) {
              setState(() => _notificationsEnabled = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(val ? 'Notifications enabled' : 'Notifications disabled')),
              );
            },
            activeThumbColor: AppTheme.primary,
          ),
        ),
      ],
    );
  }
}
