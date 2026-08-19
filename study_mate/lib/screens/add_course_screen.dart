import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/widgets/inputs/custom_text_field.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _teacherController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _teacherController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      try {
        final courseProvider = Provider.of<CourseProvider>(context, listen: false);
        await courseProvider.addCourse(
          _nameController.text.trim(),
          _codeController.text.trim(),
          _teacherController.text.trim(),
          int.tryParse(_creditsController.text) ?? 3,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course added successfully!')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add course: $e'), backgroundColor: AppTheme.error));
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Add New Course'),
        backgroundColor: AppTheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                label: 'Course Name',
                hintText: 'e.g. Data Structures',
                prefixIcon: Icons.book_outlined,
                controller: _nameController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Course Code',
                hintText: 'e.g. CS301',
                prefixIcon: Icons.tag,
                controller: _codeController,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Instructor',
                hintText: 'e.g. Prof. Smith',
                prefixIcon: Icons.person_outline,
                controller: _teacherController,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Credit Hours',
                hintText: 'e.g. 3',
                prefixIcon: Icons.numbers,
                controller: _creditsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveCourse,
                  child: _isSaving 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                    : const Text('Save Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
