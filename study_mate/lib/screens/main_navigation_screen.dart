import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_mate/core/theme/app_theme.dart';
import 'package:study_mate/providers/profile_provider.dart';
import 'package:study_mate/providers/course_provider.dart';
import 'package:study_mate/providers/schedule_provider.dart';
import 'package:study_mate/widgets/navigation/app_drawer.dart';
import 'package:study_mate/screens/dashboard_screen.dart';
import 'package:study_mate/screens/academics_screen.dart';
import 'package:study_mate/screens/study_hub_screen.dart';
import 'package:study_mate/screens/tools_screen.dart';
import 'package:study_mate/screens/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).fetchProfile();
      Provider.of<CourseProvider>(context, listen: false).fetchCourses();
      Provider.of<ScheduleProvider>(context, listen: false).fetchSchedules();
    });
  }

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AcademicsScreen(),
    const StudyHubScreen(),
    const ToolsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      body: Row(
        children: [
          if (!isMobile)
            AppDrawer(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: isMobile
          ? Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ClipRRect(
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppTheme.primary,
                  unselectedItemColor: AppTheme.onSurfaceVariant,
                  selectedLabelStyle: theme.textTheme.labelLarge,
                  unselectedLabelStyle: theme.textTheme.labelLarge,
                  items: [
                    _buildNavItem(Icons.home, Icons.home_outlined, 'Home', 0),
                    _buildNavItem(Icons.school, Icons.school_outlined, 'Academics', 1),
                    _buildNavItem(Icons.menu_book, Icons.menu_book_outlined, 'Study', 2),
                    _buildNavItem(Icons.calculate, Icons.calculate_outlined, 'Tools', 3),
                    _buildNavItem(Icons.person, Icons.person_outline, 'Profile', 4),
                  ],
                ),
              ),
            )
          : null,
      floatingActionButton: isMobile && _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppTheme.secondaryContainer,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            )
          : null,
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData activeIcon, IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(_selectedIndex == index ? activeIcon : icon),
      label: label,
    );
  }
}
