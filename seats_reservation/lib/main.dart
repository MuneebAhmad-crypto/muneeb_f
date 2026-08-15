import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notifier.dart';
import 'data_service.dart';
import 'screens.dart';
import 'models.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await AppNotifier.init();
  
  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lY2J6Ym5mZ3pseXZ0eXJ1bHJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ1NDAwNDcsImV4cCI6MjEwMDExNjA0N30.xNkrQWkCrdHEv3YjtrgWHKFX66VBYH77fS1bON0krts',
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => DataService(),
      child: const SeatReservationApp(),
    ),
  );
}

class SeatReservationApp extends StatelessWidget {
  const SeatReservationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'We Connect Seats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF003C90),
          primary: const Color(0xFF003C90),
          surface: const Color(0xFFF9F9FF),
          onSurface: const Color(0xFF111C2D),
          secondaryContainer: const Color(0xFFD0E1FB),
          onSecondaryContainer: const Color(0xFF54647A),
          outlineVariant: const Color(0xFFC3C6D5),
          outline: const Color(0xFF737784),
          error: const Color(0xFFBA1A1A),
          surfaceContainerHighest: const Color(0xFFD8E3FB),
        ),
        textTheme: GoogleFonts.interTextTheme(),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFC3C6D5), width: 1),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF9F9FF),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.inter(
            color: const Color(0xFF003C90),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: const Color(0xFFE7EEFF),
          indicatorColor: const Color(0xFFD0E1FB),
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final ds = Provider.of<DataService>(context);
    
    if (ds.currentUser == null) {
      return const AuthScreen();
    }
    
    if (ds.currentUser!.role == UserRole.admin) {
      return const AdminDashboard();
    } else {
      return const StudentDashboard();
    }
  }
}
