import 'package:flutter/material.dart';

void main() {
  runApp(const FitnessTrackerApp());
}

class FitnessTrackerApp extends StatelessWidget {
  const FitnessTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _steps = 0;

  void _addSteps() {
    setState(() {
      _steps += 500;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Dashboard'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(
              context,
              title: 'Steps',
              value: '$_steps',
              subtitle: 'Goal: 10,000',
              icon: Icons.directions_walk,
              color: Colors.blue,
              progress: (_steps / 10000).clamp(0.0, 1.0),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Calories',
                    value: '450',
                    subtitle: 'kcal',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    title: 'Heart Rate',
                    value: '72',
                    subtitle: 'bpm',
                    icon: Icons.favorite,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            _buildActivityTile(
              title: 'Morning Run',
              time: 'Today, 7:30 AM',
              duration: '30 min',
              icon: Icons.run_circle,
            ),
            _buildActivityTile(
              title: 'Evening Yoga',
              time: 'Yesterday, 6:00 PM',
              duration: '45 min',
              icon: Icons.self_improvement,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSteps,
        label: const Text('Add Steps'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    double? progress,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 30),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withAlpha(51),
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({
    required String title,
    required String time,
    required String duration,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: Text(duration),
      ),
    );
  }
}
