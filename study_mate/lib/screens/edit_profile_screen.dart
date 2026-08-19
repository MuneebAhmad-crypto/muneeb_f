import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/widgets/inputs/custom_text_field.dart';
import 'package:file_picker/file_picker.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _uniController;
  late TextEditingController _regController;
  late TextEditingController _phoneController;
  late TextEditingController _semesterController;
  String? _avatarUrl;
  String? _newProfilePicPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile?['name'] ?? '');
    _uniController = TextEditingController(text: profile?['university'] ?? '');
    _regController = TextEditingController(text: profile?['reg_number'] ?? '');
    _phoneController = TextEditingController(text: profile?['phone'] ?? '');
    _semesterController = TextEditingController(text: profile?['semester']?.toString() ?? '');
    _avatarUrl = profile?['avatar_url'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _uniController.dispose();
    _regController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        _newProfilePicPath = result.files.single.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      String? finalAvatarUrl = _avatarUrl;
      if (_newProfilePicPath != null) {
        try {
          finalAvatarUrl = await SupabaseService().uploadAvatar(_newProfilePicPath!);
        } catch (e) {
          debugPrint('Avatar upload failed: $e');
        }
      }

      await profileProvider.updateProfile({
        'name': _nameController.text.trim(),
        'university': _uniController.text.trim(),
        'reg_number': _regController.text.trim(),
        'phone': _phoneController.text.trim(),
        'semester': int.tryParse(_semesterController.text.trim()) ?? 1,
        'avatar_url': finalAvatarUrl,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(onPressed: _saveProfile, icon: const Icon(Icons.check, color: AppTheme.primary)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppTheme.surfaceVariant,
                      backgroundImage: _newProfilePicPath != null 
                        ? FileImage(File(_newProfilePicPath!)) 
                        : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null) as ImageProvider?,
                      child: (_newProfilePicPath == null && _avatarUrl == null) 
                        ? const Icon(Icons.person, size: 60, color: AppTheme.outline) 
                        : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(label: 'Full Name', hintText: 'Your Name', controller: _nameController, prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              CustomTextField(label: 'University', hintText: 'University Name', controller: _uniController, prefixIcon: Icons.account_balance_outlined),
              const SizedBox(height: 16),
              CustomTextField(label: 'Registration Number', hintText: 'FA24-BSE-091', controller: _regController, prefixIcon: Icons.fingerprint),
              const SizedBox(height: 16),
              CustomTextField(label: 'Semester', hintText: 'e.g. 1', controller: _semesterController, keyboardType: TextInputType.number, prefixIcon: Icons.school_outlined),
              const SizedBox(height: 16),
              CustomTextField(label: 'Phone Number', hintText: '03xx-xxxxxxx', controller: _phoneController, keyboardType: TextInputType.phone, prefixIcon: Icons.phone_outlined),
              const SizedBox(height: 32),
              ElevatedButton(onPressed: _isSaving ? null : _saveProfile, child: const Text('Save Changes')),
            ],
          ),
        ),
      ),
    );
  }
}
