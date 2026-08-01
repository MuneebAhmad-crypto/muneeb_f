import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    anonKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );
  runApp(const MyApp());
}

// 1. Define a Data Model for Food Items
class FoodItem {
  final String title;
  final String description;
  final String price;
  final double rating;
  final String imageUrl;

  const FoodItem({
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.imageUrl,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 2. List of Food Items Data
  final List<FoodItem> foodList = const [
    FoodItem(
      title: 'Double Cheeseburger',
      description: 'Beef patty, cheddar cheese, special sauce',
      price: 'Rs. 1,500',
      rating: 4.9,
      imageUrl:
      'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=600',
    ),
    FoodItem(
      title: 'Pepperoni Pizza',
      description: 'Mozzarella, pepperoni, tomato sauce',
      price: 'Rs. 2,200',
      rating: 4.8,
      imageUrl:
      'https://images.unsplash.com/photo-1534308983496-4fabb1a015ee?auto=format&fit=crop&q=80&w=600',
    ),
    FoodItem(
      title: 'Crispy Chicken Wrap',
      description: 'Fried chicken, lettuce, mayonnaise, tortilla',
      price: 'Rs. 950',
      rating: 4.7,
      imageUrl:
      'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&q=80&w=600',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        appBar: AppBar(
          title: const Text(
            'Menu',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
        // 3. Render items using ListView.builder
        body: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: foodList.length,
          itemBuilder: (context, index) {
            final item = foodList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FoodItemCard(foodItem: item),
            );
          },
        ),
      ),
    );
  }
}

// 4. Update Card Widget to accept dynamic data
class FoodItemCard extends StatelessWidget {
  final FoodItem foodItem;

  const FoodItemCard({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                foodItem.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    foodItem.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    Text(
                      ' ${foodItem.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              foodItem.description,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  foodItem.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}