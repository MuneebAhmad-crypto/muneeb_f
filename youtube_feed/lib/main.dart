import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: YTFeedScreen()));

class YTFeedScreen extends StatelessWidget {
  const YTFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = [
      {'title': 'Flutter Crash Course 2026 - Complete Guide', 'channel': 'Tech Academy', 'views': '250K views • 3 days ago', 'thumb': 'https://picsum.photos/400/220?random=21', 'duration': '18:45'},
      {'title': 'Build a Full-Stack App with Node & Postgres', 'channel': 'Code With Chris', 'views': '120K views • 1 week ago', 'thumb': 'https://picsum.photos/400/220?random=22', 'duration': '42:10'},
      {'title': '10 UI Design Tips You Must Know', 'channel': 'Design Sense', 'views': '89K views • 2 weeks ago', 'thumb': 'https://picsum.photos/400/220?random=23', 'duration': '12:05'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('YouTube Home'), actions: const [Icon(Icons.cast), SizedBox(width: 16), Icon(Icons.search), SizedBox(width: 16)]),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final v = videos[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Stack(
                  children: [
                    Image.network(v['thumb']!, width: double.infinity, height: 210, fit: BoxFit.cover),
                    Positioned(
                      right: 8, bottom: 8,
                      child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), color: Colors.black87, child: Text(v['duration']!, style: const TextStyle(color: Colors.white, fontSize: 12))),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${30 + index}')),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(v['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${v['channel']} • ${v['views']}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                      ),
                      const Icon(Icons.more_vert, size: 20),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}