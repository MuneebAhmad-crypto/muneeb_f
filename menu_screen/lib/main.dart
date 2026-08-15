import 'package:flutter/material.dart';

void main() {
  runApp(const MenuApp());
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Italian Bistro',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
        brightness: Brightness.light,
      ),
      home: const RestaurantMenuScreen(),
    );
  }
}

class Dish {
  final String name;
  final String description;
  final String price;
  final String imageUrl;

  const Dish({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
  });
}

class RestaurantMenuScreen extends StatelessWidget {
  const RestaurantMenuScreen({super.key});

  static const List<Dish> _dishes = [
    Dish(
      name: 'Margherita Pizza',
      description: 'Fresh mozzarella, tomatoes, and basil.',
      price: '\$14.99',
      imageUrl: 'https://picsum.photos/150?random=51',
    ),
    Dish(
      name: 'Truffle Pasta',
      description: 'Creamy parmesan with black truffle sauce.',
      price: '\$18.50',
      imageUrl: 'https://picsum.photos/150?random=52',
    ),
    Dish(
      name: 'Caesar Salad',
      description: 'Crisp romaine, parmesan, and garlic croutons.',
      price: '\$11.00',
      imageUrl: 'https://picsum.photos/150?random=53',
    ),
    Dish(
      name: 'Lasagna Bolognese',
      description: 'Layered pasta with rich meat sauce and cheese.',
      price: '\$16.00',
      imageUrl: 'https://picsum.photos/150?random=54',
    ),
    Dish(
      name: 'Tiramisu',
      description: 'Classic Italian dessert with coffee and mascarpone.',
      price: '\$8.50',
      imageUrl: 'https://picsum.photos/150?random=55',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Italian Bistro'),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(label: const Text('All'), selected: true, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Pizza'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Pasta'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Salads'), selected: false, onSelected: (_) {}),
                  const SizedBox(width: 8),
                  FilterChip(label: const Text('Desserts'), selected: false, onSelected: (_) {}),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => DishCard(dish: _dishes[index]),
                childCount: _dishes.length,
              ),
            ),
          ),
          // Add some bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Order Now'),
        icon: const Icon(Icons.restaurant_menu),
      ),
    );
  }
}

class DishCard extends StatelessWidget {
  final Dish dish;

  const DishCard({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: colorScheme.outlineVariant.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(
                tag: dish.name,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    dish.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 100,
                        height: 100,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: colorScheme.errorContainer,
                      child: Icon(Icons.broken_image, color: colorScheme.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dish.description,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dish.price,
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        IconButton.filledTonal(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 20),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
