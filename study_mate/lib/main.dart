import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/screens/welcome_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_mate/core/constants/app_constants.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/auth_provider.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
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
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            return const MainNavigationScreen();
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}
