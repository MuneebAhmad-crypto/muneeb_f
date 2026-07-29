import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    anonKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );

  runApp(const MaterialApp(
    home: Task3PricingScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Task3PricingScreen extends StatelessWidget {
  const Task3PricingScreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchPlans() async {
    final response = await supabase.from('pricing_plans').select();
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Plans & Pricing')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPlans(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final plans = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: plans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final plan = plans[index];
              final List<String> features = List<String>.from(plan['features'] ?? []);
              return PricingCard(
                planName: plan['plan_name'] ?? '',
                price: plan['price'] ?? '',
                billingPeriod: plan['billing_period'] ?? '/month',
                features: features,
                isPopular: plan['is_popular'] ?? false,
              );
            },
          );
        },
      ),
    );
  }
}

class PricingCard extends StatelessWidget {
  final String planName;
  final String price;
  final String billingPeriod;
  final List<String> features;
  final bool isPopular;

  const PricingCard({
    Key? key,
    required this.planName,
    required this.price,
    required this.billingPeriod,
    required this.features,
    required this.isPopular,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isPopular ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isPopular ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Fixed here
        children: [
          if (isPopular) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C5CE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'MOST POPULAR',
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            planName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPopular ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline, // Fixed here
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: isPopular ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                billingPeriod,
                style: TextStyle(
                  fontSize: 14,
                  color: isPopular ? Colors.grey.shade400 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...features.map(
                (feature) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: isPopular ? const Color(0xFF00B894) : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: TextStyle(color: isPopular ? Colors.grey.shade300 : Colors.grey.shade800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}