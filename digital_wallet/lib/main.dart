import 'package:flutter/material.dart';

void main() {
  runApp(const DigitalWalletApp());
}

class DigitalWalletApp extends StatelessWidget {
  const DigitalWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Wallet',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      home: const WalletDashboardScreen(),
    );
  }
}

class WalletDashboardScreen extends StatelessWidget {
  const WalletDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back,', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('Alex Johnson', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Badge(
              label: Text('2'),
              child: Icon(Icons.notifications_outlined),
            ),
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.deepPurple,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCreditCard(),
              const SizedBox(height: 30),
              const Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 8),
              _buildTransactionList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        elevation: 10,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_filled), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Wallet'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Stats'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildCreditCard() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2575FC).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  SizedBox(height: 4),
                  Text('\$12,450.80', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.contactless_outlined, color: Colors.white),
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('**** **** **** 4582', style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 2)),
                  SizedBox(height: 4),
                  Text('EXP 12/26', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Column(
                children: [
                  Stack(
                    children: [
                      Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.red.withOpacity(0.8), shape: BoxShape.circle)),
                      Positioned(left: 12, child: Container(width: 24, height: 24, decoration: BoxDecoration(color: Colors.orange.withOpacity(0.8), shape: BoxShape.circle))),
                    ],
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _quickActionItem(Icons.arrow_upward_rounded, 'Send', Colors.blue),
        _quickActionItem(Icons.arrow_downward_rounded, 'Receive', Colors.green),
        _quickActionItem(Icons.qr_code_scanner_rounded, 'Scan', Colors.orange),
        _quickActionItem(Icons.grid_view_rounded, 'More', Colors.purple),
      ],
    );
  }

  Widget _quickActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {'name': 'Apple Store', 'type': 'Entertainment', 'amount': '- \$199.00', 'icon': Icons.apple, 'color': Colors.black},
      {'name': 'Grocery Store', 'type': 'Shopping', 'amount': '- \$45.20', 'icon': Icons.shopping_bag, 'color': Colors.orange},
      {'name': 'Salary', 'type': 'Income', 'amount': '+ \$4,500.00', 'icon': Icons.payments, 'color': Colors.green},
      {'name': 'Netflix', 'type': 'Subscription', 'amount': '- \$15.99', 'icon': Icons.movie, 'color': Colors.red},
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final tx = transactions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (tx['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tx['icon'] as IconData, color: tx['color'] as Color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(tx['type'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Text(
                tx['amount'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: (tx['amount'] as String).contains('+') ? Colors.green : Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
