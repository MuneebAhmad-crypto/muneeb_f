import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'calculation.dart';
import 'supabase_service.dart';
import 'calculator_keypad.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    anonKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final SupabaseService _dbService = SupabaseService();

  String _input = '';
  String _result = '0';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '0';
      } else if (value == '=') {
        _calculateAndSave();
      } else {
        _input += value;
      }
    });
  }

  Future<void> _calculateAndSave() async {
    try {
      double calc = 0;
      if (_input.contains('+')) {
        var parts = _input.split('+');
        calc = double.parse(parts[0]) + double.parse(parts[1]);
      } else if (_input.contains('-')) {
        var parts = _input.split('-');
        calc = double.parse(parts[0]) - double.parse(parts[1]);
      } else if (_input.contains('*')) {
        var parts = _input.split('*');
        calc = double.parse(parts[0]) * double.parse(parts[1]);
      } else if (_input.contains('/')) {
        var parts = _input.split('/');
        calc = double.parse(parts[0]) / double.parse(parts[1]);
      } else {
        return;
      }

      String finalResult =
      calc.toStringAsFixed(calc.truncateToDouble() == calc ? 0 : 2);

      setState(() {
        _result = finalResult;
      });

      await _dbService.addCalculation(_input, finalResult);
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compact Calculator'),
        backgroundColor: Colors.black12,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistoryDrawer(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Screen Display
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
                      style: const TextStyle(fontSize: 24, color: Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _result,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Compact Keypad
            CalculatorKeypad(onButtonPressed: _onButtonPressed),
          ],
        ),
      ),
    );
  }

  // --- HISTORY DRAWER SHEET ---
  void _showHistoryDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Calculation History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                onPressed: () async {
                  await _dbService.clearHistory();
                  if (context.mounted) Navigator.pop(context);
                },
              )
            ],
          ),
          body: FutureBuilder<List<Calculation>>(
            future: _dbService.getHistory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final history = snapshot.data ?? [];

              if (history.isEmpty) {
                return const Center(child: Text('No history available.'));
              }

              return ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  return ListTile(
                    title: Text('${item.expression} = ${item.result}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await _dbService.deleteCalculation(item.id);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}