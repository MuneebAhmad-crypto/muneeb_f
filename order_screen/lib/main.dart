import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CheckoutScreen()));

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Checkout Summary')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.location_on, color: Colors.blue),
                title: Text('Shipping Address', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('123 Innovation Way, Tech City, CA'),
                trailing: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const ListTile(
                leading: Icon(Icons.payment, color: Colors.green),
                title: Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Visa ending in **** 4821'),
                trailing: Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  _row('Subtotal', '\$518.49'),
                  _row('Shipping Fee', '\$15.00'),
                  _row('Tax', '\$41.48'),
                  const Divider(height: 20),
                  _row('Total', '\$574.97', isBold: true),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: () {},
                child: const Text('Place Order', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String amount, {bool isBold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)), Text(amount, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? Colors.blue : Colors.black))]),
  );
}