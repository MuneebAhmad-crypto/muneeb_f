import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: FBProfileScreen()));

class FBProfileScreen extends StatelessWidget {
  const FBProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(top: 0, left: 0, right: 0, height: 140, child: Image.network('https://picsum.photos/600/200', fit: BoxFit.cover)),
                      const Positioned(bottom: 0, child: CircleAvatar(radius: 54, backgroundColor: Colors.white, child: CircleAvatar(radius: 50, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60')))),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Sarah Jenkins', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Text('Software Engineer & Tech Enthusiast', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add to Story')),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit Profile')),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _postCard('Sarah Jenkins', '3 hrs ago', 'Just completed a major feature deployment! 🚀', 'https://picsum.photos/500/250?random=11'),
          _postCard('Sarah Jenkins', 'Yesterday', 'Coffee and wireframes.', 'https://picsum.photos/500/250?random=12'),
        ],
      ),
    );
  }

  Widget _postCard(String name, String time, String text, String img) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=60')),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(time),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Text(text)),
          const SizedBox(height: 8),
          Image.network(img, width: double.infinity, height: 200, fit: BoxFit.cover),
        ],
      ),
    );
  }
}