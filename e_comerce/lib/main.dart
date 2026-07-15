import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const FoodShopApp());
}

class FoodShopApp extends StatelessWidget {
  const FoodShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}