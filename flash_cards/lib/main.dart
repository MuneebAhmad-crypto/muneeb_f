import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const GKFlashCardsApp());
}

class GKFlashCardsApp extends StatelessWidget {
  const GKFlashCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "GK Flash Cards",
      home: const HomeScreen(),
    );
  }
}