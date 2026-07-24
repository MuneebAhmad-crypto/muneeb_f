import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'calculation_history.dart';

class HistoryModal extends StatefulWidget {
  const HistoryModal({super.key});

  @override
  State<HistoryModal> createState() => _HistoryModalState();
}

class _HistoryModalState extends State<HistoryModal> {
  late Future<List<CalculationHistory>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _refreshHistory();
  }

  void _refreshHistory() {
    setState(() {
      _historyFuture = DatabaseHelper.instance.getHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Calculation History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                onPressed: () async {
                  await DatabaseHelper.instance.clearAllHistory();
                  _refreshHistory();
                },
                tooltip: 'Clear All History',
              ),
            ],
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<CalculationHistory>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final historyList = snapshot.data ?? [];

                if (historyList.isEmpty) {
                  return const Center(
                    child: Text('No history saved yet.', style: TextStyle(color: Colors.grey)),
                  );
                }

                return ListView.builder(
                  itemCount: historyList.length,
                  itemBuilder: (context, index) {
                    final item = historyList[index];
                    return ListTile(
                      title: Text(
                        '${item.expression} = ${item.result}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                        onPressed: () async {
                          if (item.id != null) {
                            await DatabaseHelper.instance.deleteHistoryItem(item.id!);
                            _refreshHistory();
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}