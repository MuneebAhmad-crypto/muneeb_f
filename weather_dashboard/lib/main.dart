import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: WeatherDashboardScreen()));

class WeatherDashboardScreen extends StatelessWidget {
  const WeatherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final forecast = [
      {'day': 'Mon', 'temp': '72°', 'icon': Icons.wb_sunny, 'color': Colors.amber},
      {'day': 'Tue', 'temp': '68°', 'icon': Icons.cloud, 'color': Colors.grey},
      {'day': 'Wed', 'temp': '65°', 'icon': Icons.grain, 'color': Colors.blue},
      {'day': 'Thu', 'temp': '70°', 'icon': Icons.wb_cloudy, 'color': Colors.amberAccent},
      {'day': 'Fri', 'temp': '75°', 'icon': Icons.wb_sunny, 'color': Colors.orange},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(title: const Text('Weather Forecast')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.blue, Colors.lightBlueAccent]), borderRadius: BorderRadius.circular(20)),
              child: const Column(
                children: [
                  Text('San Francisco', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Icon(Icons.wb_sunny, color: Colors.amber, size: 64),
                  Text('72°F', style: TextStyle(color: Colors.white, fontSize: 44, fontWeight: FontWeight.bold)),
                  Text('Sunny', style: TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('5-Day Forecast', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: forecast.length,
                itemBuilder: (context, index) {
                  final f = forecast[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(f['icon'] as IconData, color: f['color'] as Color),
                      title: Text(f['day'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(f['temp'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}