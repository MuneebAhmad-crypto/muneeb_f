import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: MusicPlayerScreen()));

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracks = [
      {'title': 'Midnight Dreams', 'artist': 'Lunar Echoes', 'time': '3:50'},
      {'title': 'Neon Horizon', 'artist': 'Cyber Vibe', 'time': '4:12'},
      {'title': 'Starlight Highway', 'artist': 'Aura Sky', 'time': '3:25'},
      {'title': 'Ocean Breeze', 'artist': 'Chill Acoustic', 'time': '2:58'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text('Now Playing'), backgroundColor: Colors.transparent),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.network('https://picsum.photos/300/300?random=31', height: 180, width: 180, fit: BoxFit.cover)),
                const SizedBox(height: 12),
                const Text('Midnight Dreams', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('Lunar Echoes', style: TextStyle(color: Colors.grey)),
                Slider(value: 0.4, onChanged: (v) {}, activeColor: Colors.deepPurpleAccent),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.play_circle_fill, color: Colors.deepPurpleAccent, size: 50), onPressed: () {}),
                    IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 30), onPressed: () {}),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('Up Next', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final t = tracks[index];
                return ListTile(
                  leading: ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.network('https://picsum.photos/100?random=${32 + index}', width: 48, height: 48, fit: BoxFit.cover)),
                  title: Text(t['title']!, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(t['artist']!, style: const TextStyle(color: Colors.grey)),
                  trailing: Text(t['time']!, style: const TextStyle(color: Colors.grey)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}