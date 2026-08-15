import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: SocialFeedScreen()));

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      {'user': 'Alex Morgan', 'avatar': 'https://i.pravatar.cc/150?img=12', 'time': '2 hours ago', 'image': 'https://picsum.photos/500/300?random=1', 'caption': 'Exploring mountain trails today! 🏔️', 'likes': '1.2k', 'comments': '84'},
      {'user': 'Sophia Chen', 'avatar': 'https://i.pravatar.cc/150?img=5', 'time': '4 hours ago', 'image': 'https://picsum.photos/500/300?random=2', 'caption': 'Fresh coffee and coding mornings. ☕💻', 'likes': '850', 'comments': '32'},
      {'user': 'David Miller', 'avatar': 'https://i.pravatar.cc/150?img=8', 'time': '6 hours ago', 'image': 'https://picsum.photos/500/300?random=3', 'caption': 'Sunset over the city skyline. 🌅', 'likes': '3.4k', 'comments': '142'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Social Feed'), elevation: 0),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: CircleAvatar(backgroundImage: NetworkImage(post['avatar']!)),
                  title: Text(post['user']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(post['time']!),
                  trailing: const Icon(Icons.more_vert),
                ),
                Image.network(post['image']!, width: double.infinity, height: 220, fit: BoxFit.cover),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(post['caption']!, style: TextStyle(color: Colors.grey[800])),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [const Icon(Icons.favorite_border), const SizedBox(width: 4), Text(post['likes']!)]),
                      Row(children: [const Icon(Icons.chat_bubble_outline), const SizedBox(width: 4), Text(post['comments']!)]),
                      const Icon(Icons.share_outlined),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}