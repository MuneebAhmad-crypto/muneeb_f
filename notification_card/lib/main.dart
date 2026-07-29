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
    home: Task1NotificationScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class Task1NotificationScreen extends StatefulWidget {
  const Task1NotificationScreen({Key? key}) : super(key: key);

  @override
  State<Task1NotificationScreen> createState() => _Task1NotificationScreenState();
}

class _Task1NotificationScreenState extends State<Task1NotificationScreen> {
  late final Stream<List<Map<String, dynamic>>> _notificationStream;

  @override
  void initState() {
    super.initState();
    _notificationStream = supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false);
  }

  Future<void> _toggleReadState(String id, bool currentStatus) async {
    await supabase.from('notifications').update({'is_read': !currentStatus}).eq('id', id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _notificationStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final notifications = snapshot.data!;
          if (notifications.isEmpty) return const Center(child: Text('No notifications.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return NotificationCard(
                title: item['title'] ?? '',
                message: item['message'] ?? '',
                timeAgo: item['time_ago'] ?? '',
                isRead: item['is_read'] ?? false,
                onTap: () => _toggleReadState(item['id'], item['is_read'] ?? false),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final VoidCallback onTap;

  const NotificationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.isRead,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: isRead ? Colors.white : Colors.indigo.shade50.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isRead ? Colors.grey.shade200 : Colors.indigo.shade100),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF6C5CE7), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Text(timeAgo, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(message, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
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