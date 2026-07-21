import 'package:flutter/material.dart';

class CalculatorKeypad extends StatelessWidget {
  final Function(String) onButtonPressed;

  const CalculatorKeypad({super.key, required this.onButtonPressed});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      '7', '8', '9', '/',
      '4', '5', '6', '*',
      '1', '2', '3', '-',
      'C', '0', '=', '+'
    ];

    return SizedBox(
      height: 260, // Compact height for small screens
      child: GridView.count(
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        childAspectRatio: 1.4, // Shorter, wider buttons
        children: buttons.map((text) {
          final isSpecial = text == '=' || text == 'C';
          return Padding(
            padding: const EdgeInsets.all(3.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSpecial ? Colors.teal : Colors.grey[200],
                foregroundColor: isSpecial ? Colors.white : Colors.black,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => onButtonPressed(text),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}