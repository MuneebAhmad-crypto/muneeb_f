import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/auth_provider.dart';
import 'package:study_mate/screens/main_navigation_screen.dart';
import 'package:study_mate/widgets/inputs/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        name: _nameController.text.trim(),
      );

      if (success && mounted) {
        // Also update profile name if needed, but Supabase signUp doesn't directly support name in user metadata without extra steps
        // For simplicity, we just navigate to dashboard where profile fetching will happen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Signup failed'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 32, offset: const Offset(0, 12)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  const Text('Join StudyMate to organize your student life', style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14), textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'John Doe',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) => value == null || value.isEmpty ? 'Please enter your name' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'student@university.edu',
                    prefixIcon: Icons.mail_outline,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Password',
                    hintText: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: _obscurePassword,
                    controller: _passwordController,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (value) => value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 32),
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleSignup,
                        child: auth.isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Sign Up'),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 14)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Sign In', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
