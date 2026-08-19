import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  // Hardcoded to light mode as requested by user
  final ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => false;

  void toggleTheme(bool isDark) {
    // No-op to prevent theme changes
    notifyListeners();
  }
}
