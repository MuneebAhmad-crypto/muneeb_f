import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WalletHomePage(),
    );
  }
}

class WalletHomePage extends StatefulWidget {
  const WalletHomePage({super.key});

  @override
  State<WalletHomePage> createState() => _WalletHomePageState();
}

class _WalletHomePageState extends State<WalletHomePage> {
  double _balance = 1250.50;

  void _addFunds() {
    setState(() {
      _balance += 100.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        title: const Text('My Wallet'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBalanceCard(context),
            const SizedBox(height: 24),
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: const [
                  TransactionItem(
                    title: 'Grocery Store',
                    amount: -45.20,
                    date: 'Today',
                    icon: Icons.shopping_cart,
                  ),
                  TransactionItem(
                    title: 'Salary Deposit',
                    amount: 3200.00,
                    date: 'Yesterday',
                    icon: Icons.account_balance_wallet,
                  ),
                  TransactionItem(
                    title: 'Electric Bill',
                    amount: -120.50,
                    date: '2 days ago',
                    icon: Icons.electric_bolt,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addFunds,
        label: const Text('Add Funds'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Balance',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${_balance.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final String date;
  final IconData icon;

  const TransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = amount < 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.onSecondaryContainer),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date),
        trailing: Text(
          '${isNegative ? "" : "+"}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isNegative ? Colors.red : Colors.green,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
