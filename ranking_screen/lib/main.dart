import 'package:flutter/material.dart';

void main() => runApp(const RankingApp());

class RankingApp extends StatelessWidget {
  const RankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const LeaderboardScreen(),
    );
  }
}

class LeaderboardUser {
  final int rank;
  final String name;
  final String score;
  final String avatarUrl;

  LeaderboardUser({
    required this.rank,
    required this.name,
    required this.score,
    required this.avatarUrl,
  });
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<LeaderboardUser> users = [
      LeaderboardUser(rank: 1, name: 'Emma Watson', score: '2,450', avatarUrl: 'https://i.pravatar.cc/150?u=1'),
      LeaderboardUser(rank: 2, name: 'Liam Neeson', score: '2,100', avatarUrl: 'https://i.pravatar.cc/150?u=2'),
      LeaderboardUser(rank: 3, name: 'Sophia Grey', score: '1,950', avatarUrl: 'https://i.pravatar.cc/150?u=3'),
      LeaderboardUser(rank: 4, name: 'Noah Centineo', score: '1,800', avatarUrl: 'https://i.pravatar.cc/150?u=4'),
      LeaderboardUser(rank: 5, name: 'Olivia Rodrigo', score: '1,650', avatarUrl: 'https://i.pravatar.cc/150?u=5'),
      LeaderboardUser(rank: 6, name: 'Tom Holland', score: '1,500', avatarUrl: 'https://i.pravatar.cc/150?u=6'),
      LeaderboardUser(rank: 7, name: 'Zendaya', score: '1,420', avatarUrl: 'https://i.pravatar.cc/150?u=7'),
    ];

    final topThree = users.take(3).toList();
    final remaining = users.skip(3).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPodium(topThree),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                itemCount: remaining.length,
                separatorBuilder: (context, index) => const Divider(height: 25, color: Colors.black12),
                itemBuilder: (context, index) {
                  final user = remaining[index];
                  return Row(
                    children: [
                      Text(
                        '${user.rank}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 20),
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.avatarUrl),
                        radius: 22,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        user.score,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'pts',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardUser> topThree) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildPodiumItem(topThree[1], 80, Colors.grey[300]!, '2nd'),
          _buildPodiumItem(topThree[0], 100, Colors.amber[400]!, '1st'),
          _buildPodiumItem(topThree[2], 70, Colors.brown[300]!, '3rd'),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(LeaderboardUser user, double height, Color color, String rankLabel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 3),
              ),
              child: CircleAvatar(
                radius: height / 2.5,
                backgroundImage: NetworkImage(user.avatarUrl),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                rankLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          user.name.split(' ')[0],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          '${user.score} pts',
          style: TextStyle(
            color: Colors.indigo[700],
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
