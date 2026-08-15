import 'package:flutter/material.dart';

void main() => runApp(const BookStoreApp());

class BookStoreApp extends StatelessWidget {
  const BookStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Store',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BookStoreScreen(),
    );
  }
}

class Book {
  final String title;
  final String author;
  final String price;
  final String imageUrl;

  const Book({
    required this.title,
    required this.author,
    required this.price,
    required this.imageUrl,
  });
}

class BookStoreScreen extends StatelessWidget {
  const BookStoreScreen({super.key});

  static const List<Book> books = [
    Book(
      title: 'Atomic Habits',
      author: 'James Clear',
      price: '\$18.99',
      imageUrl: 'https://picsum.photos/100/150?random=91',
    ),
    Book(
      title: 'Deep Work',
      author: 'Cal Newport',
      price: '\$15.50',
      imageUrl: 'https://picsum.photos/100/150?random=92',
    ),
    Book(
      title: 'The Psychology of Money',
      author: 'Morgan Housel',
      price: '\$16.80',
      imageUrl: 'https://picsum.photos/100/150?random=93',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bestselling Books'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: books.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => BookListItem(book: books[index]),
      ),
    );
  }
}

class BookListItem extends StatelessWidget {
  final Book book;

  const BookListItem({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.imageUrl,
                  width: 80,
                  height: 110,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.book),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      book.author,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book.price,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 18,
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () {},
                          style: FilledButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                          ),
                          child: const Text('Add'),
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
