import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MaterialApp(
    home: Task5EmptyStateScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Task5EmptyStateScreen extends StatefulWidget {
  const Task5EmptyStateScreen({Key? key}) : super(key: key);

  @override
  State<Task5EmptyStateScreen> createState() => _Task5EmptyStateScreenState();
}

class _Task5EmptyStateScreenState extends State<Task5EmptyStateScreen> {
  late final Stream<List<Map<String, dynamic>>> _dataStream;

  @override
  void initState() {
    super.initState();
    // Streams data live from the Supabase notifications table
    _dataStream = supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  // Action button creates a record in Supabase to test switching out of the Empty State
  Future<void> _createSampleData() async {
    try {
      await supabase.from('notifications').insert({
        'title': 'Sample Notification',
        'message': 'This row was created from the empty state action button.',
        'time_ago': 'Just now',
        'is_read': false,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding record: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Empty State Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear All Data (Test Empty State)',
            onPressed: () async {
              // Delete all records to trigger the Empty State UI again
              await supabase.from('notifications').delete().neq('title', '');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _dataStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;

          // 1. SHOW EMPTY STATE WHEN NO DATA IS FOUND
          if (items.isEmpty) {
            return EmptyStateWidget(
              title: 'No Data Available',
              description:
              'Your Supabase notifications table is currently empty. Tap the button below to insert your first record.',
              icon: Icons.inbox_rounded,
              buttonText: 'Add First Record',
              onActionPressed: _createSampleData,
            );
          }

          // 2. SHOW DATA LIST WHEN ITEMS EXIST
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: ListTile(
                  leading: const Icon(Icons.notifications, color: Color(0xFF6C5CE7)),
                  title: Text(item['title'] ?? ''),
                  subtitle: Text(item['message'] ?? ''),
                  trailing: Text(item['time_ago'] ?? ''),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final VoidCallback onActionPressed;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonText,
    required this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: const Color(0xFF6C5CE7)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}