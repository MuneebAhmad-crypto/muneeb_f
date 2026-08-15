import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TransactionHistoryScreen(),
    ));

class Transaction {
  final String title;
  final String date;
  final double amount;
  final bool isDebit;
  final IconData icon;

  const Transaction({
    required this.title,
    required this.date,
    required this.amount,
    required this.isDebit,
    required this.icon,
  });
}

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Moved data to a structured list of objects
    final List<Transaction> transactions = [
      const Transaction(
        title: 'Apple Store Purchase',
        date: 'Today, 2:45 PM',
        amount: 999.00,
        isDebit: true,
        icon: Icons.shopping_bag_outlined,
      ),
      const Transaction(
        title: 'Salary Deposit',
        date: 'Yesterday, 9:00 AM',
        amount: 3500.00,
        isDebit: false,
        icon: Icons.account_balance_wallet_outlined,
      ),
      const Transaction(
        title: 'Starbucks Coffee',
        date: 'Aug 12, 10:15 AM',
        amount: 5.75,
        isDebit: true,
        icon: Icons.coffee_outlined,
      ),
      const Transaction(
        title: 'Freelance Payment',
        date: 'Aug 10, 4:30 PM',
        amount: 450.00,
        isDebit: false,
        icon: Icons.payments_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBalanceHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _TransactionItem(transaction: transactions[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '\$2,945.25',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionChip(Icons.arrow_downward, 'Income', Colors.green),
              _buildActionChip(Icons.arrow_upward, 'Expense', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(transaction.icon, color: Colors.black87),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          transaction.date,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        trailing: Text(
          '${transaction.isDebit ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: transaction.isDebit ? Colors.redAccent : Colors.green[700],
          ),
        ),
      ),
    );
  }
}
