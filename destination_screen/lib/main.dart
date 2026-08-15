import 'package:flutter/material.dart';

void main() {
  runApp(const TravelApp());
}

class TravelApp extends StatelessWidget {
  const TravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Destinations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
      ),
      home: const TravelDestinationsScreen(),
    );
  }
}

class Destination {
  final String name;
  final String country;
  final String imageUrl;

  const Destination({
    required this.name,
    required this.country,
    required this.imageUrl,
  });
}

class TravelDestinationsScreen extends StatelessWidget {
  const TravelDestinationsScreen({super.key});

  static const List<Destination> destinations = [
    Destination(
      name: 'Bali',
      country: 'Indonesia',
      imageUrl: 'https://picsum.photos/400/600?random=71',
    ),
    Destination(
      name: 'Kyoto',
      country: 'Japan',
      imageUrl: 'https://picsum.photos/400/600?random=72',
    ),
    Destination(
      name: 'Santorini',
      country: 'Greece',
      imageUrl: 'https://picsum.photos/400/600?random=73',
    ),
    Destination(
      name: 'Swiss Alps',
      country: 'Switzerland',
      imageUrl: 'https://picsum.photos/400/600?random=74',
    ),
    Destination(
      name: 'Paris',
      country: 'France',
      imageUrl: 'https://picsum.photos/400/600?random=75',
    ),
    Destination(
      name: 'Rome',
      country: 'Italy',
      imageUrl: 'https://picsum.photos/400/600?random=76',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Top Destinations',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return DestinationCard(destination: destinations[index]);
                },
                childCount: destinations.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {},
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(
                destination.imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 0.8, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          destination.country,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
