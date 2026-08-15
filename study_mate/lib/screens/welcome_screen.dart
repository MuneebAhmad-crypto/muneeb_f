import 'package:flutter/material.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/screens/signup_screen.dart';
import 'package:study_mate/screens/login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      body: SafeArea(
        child: Flex(
          direction: isMobile ? Axis.vertical : Axis.horizontal,
          children: [
            // Left Side: Hero Illustration
            Expanded(
              flex: isMobile ? 2 : 1,
              child: Container(
                width: double.infinity,
                color: AppTheme.primaryFixed.withOpacity(0.3),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.0,
                            colors: [
                              AppTheme.primary.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Image.network(
                          'https://lh3.googleusercontent.com/aida-public/AB6AXuC82VsI8RC8MWVyLyMoKp_wW00cJxpBLUsqMOa2rA0mhMjjf2L5hz_C7toMFicygxf-Huvqco8m1TEI3Qmj-sgJYgXHfyqtt1TCHw30F8a-4yK13UW4gZfQ09ngds4CbUan_MC5WBkVxNMZO7NWqH_QOxCAa1LEfv4FAFveR-p3UTw7SpTTjUJoYKIWbqz2SLCnM-jv3hGiHgYNudgZjWwqhoj14FLeN1hIunXYbAJv5keoEmFB_o5ACg',
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.school, size: 100, color: AppTheme.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right Side: Content & Actions
            Expanded(
              flex: isMobile ? 3 : 1,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Brand Header
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'StudyMate',
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Value Proposition
                      Text(
                        'Welcome to\nStudyMate',
                        style: theme.textTheme.displayLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Everything you need to stay on top of university. Manage courses, track assignments, and boost your productivity all in one place.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Action Buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.onSecondary,
                          shadowColor: AppTheme.secondary.withOpacity(0.2),
                          elevation: 8,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Get Started'),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(color: AppTheme.outlineVariant),
                        ),
                        child: Text(
                          'I already have an account',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: AppTheme.primary,
                          ),
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
    );
  }
}
