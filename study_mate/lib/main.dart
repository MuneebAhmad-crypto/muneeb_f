import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/auth_provider.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/providers/note_provider.dart';
import 'package:study_mate/providers/flashcard_provider.dart';
import 'package:study_mate/providers/assignment_provider.dart';
import 'package:study_mate/providers/attendance_provider.dart';
import 'package:study_mate/providers/exam_provider.dart';
import 'package:study_mate/providers/task_provider.dart';
import 'package:study_mate/providers/quiz_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase with publishable key
  await Supabase.initialize(
    url: 'https://srtqadaxhitddbdgwzgg.supabase.co',
    publishableKey: 'sb_publishable_t-bLw_YOw3nQURnlRFRfNQ_mqZJxBLL',
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => FlashcardProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyMate',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
