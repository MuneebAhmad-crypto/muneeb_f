import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: InstaProfileScreen()));

class InstaProfileScreen extends StatelessWidget {
  const InstaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final highlights = ['Travel', 'Design', 'Code', 'Food', 'Fitness'];

    return Scaffold(
      appBar: AppBar(title: const Text('johndoe_design'), actions: const [Icon(Icons.add_box_outlined), SizedBox(width: 12), Icon(Icons.menu), SizedBox(width: 16)]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 40, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=33')),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [_stat('54', 'Posts'), _stat('12.5k', 'Followers'), _stat('450', 'Following')],
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          const Text('John Doe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Text('UI/UX Designer | Mobile App Developer 📱\nBuilding digital experiences that matter.'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () {}, child: const Text('Edit Profile'))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[200], foregroundColor: Colors.black), onPressed: () {}, child: const Text('Share Profile'))),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: highlights.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: Colors.grey[300], child: CircleAvatar(radius: 26, backgroundImage: NetworkImage('https://picsum.photos/100?random=$index'))),
                    const SizedBox(height: 4),
                    Text(highlights[index], style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2),
            itemCount: 12,
            itemBuilder: (context, index) => Image.network('https://picsum.photos/300?random=$index', fit: BoxFit.cover),
          )
        ],
      ),
    );
  }

  static Widget _stat(String val, String label) => Column(children: [Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text(label, style: const TextStyle(color: Colors.grey))]);
}