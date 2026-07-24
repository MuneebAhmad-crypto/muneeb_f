import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';
import 'database_helper.dart';
import 'calculation_history.dart';
import 'history_modal.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == '⌫') {
        if (_input.isNotEmpty) {
          _input = _input.substring(0, _input.length - 1);
        }
      } else if (value == '=') {
        _calculateResult();
      } else {
        _input += value;
      }
    });
  }

  void _calculateResult() async {
    if (_input.isEmpty) return;

    try {
      String sanitized = _input.replaceAll('×', '*').replaceAll('÷', '/');
      Expression expression = Expression.parse(sanitized);
      const evaluator = ExpressionEvaluator();
      var evalResult = evaluator.eval(expression, {});

      String finalResult = evalResult.toString();

      if (evalResult is double && evalResult == evalResult.roundToDouble()) {
        finalResult = evalResult.toInt().toString();
      }

      setState(() {
        _result = finalResult;
      });

      // Save using Model
      final historyItem = CalculationHistory(
        expression: _input,
        result: finalResult,
        timestamp: DateTime.now().toIso8601String(),
      );

      await DatabaseHelper.instance.insertHistory(historyItem);
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  void _openHistoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const HistoryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      'C', '⌫', '÷', '×',
      '7', '8', '9', '-',
      '4', '5', '6', '+',
      '1', '2', '3', '=',
      '0', '.'
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _openHistoryModal,
            tooltip: 'Calculation History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Display Screen
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _input,
                    style: const TextStyle(fontSize: 28, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Keypad Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: buttons.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final btn = buttons[index];
              final isOperator = ['÷', '×', '-', '+', '='].contains(btn);
              final isClear = ['C', '⌫'].contains(btn);

              return Padding(
                padding: const EdgeInsets.all(6.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOperator
                        ? Colors.orange[800]
                        : isClear
                        ? Colors.red[700]
                        : Colors.grey[850],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _onButtonPressed(btn),
                  child: Text(
                    btn,
                    style: const TextStyle(fontSize: 22, color: Colors.white),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}