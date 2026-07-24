import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Connected to the same Supabase instance
  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    anonKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );

  runApp(const AdminApp());
}

final supabase = Supabase.instance.client;

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Company Admin Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5), // Indigo Admin Theme
          primary: const Color(0xFF4F46E5),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A), // Dark Slate
          elevation: 0,
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDatabaseRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- SUPABASE ADMIN ACTIONS ---
  Future<void> _fetchDatabaseRecords({String query = ''}) async {
    setState(() => _isLoading = true);
    try {
      final builder = supabase.from('employees').select();
      final response = query.isEmpty
          ? await builder.order('id', ascending: false)
          : await builder.ilike('name', '%$query%').order('id', ascending: false);

      setState(() {
        _records = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Admin Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRecord(int id, String name, String phone, String designation, double salary) async {
    try {
      await supabase.from('employees').update({
        'name': name,
        'phone': phone,
        'designation': designation,
        'salary': salary,
      }).eq('id', id);

      _fetchDatabaseRecords(query: _searchController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully!'), backgroundColor: Color(0xFF10B981)),
        );
      }
    } catch (e) {
      debugPrint('Update Error: $e');
    }
  }

  Future<void> _deleteRecord(int id) async {
    try {
      await supabase.from('employees').delete().eq('id', id);
      _fetchDatabaseRecords(query: _searchController.text);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record deleted!'), backgroundColor: Color(0xFFEF4444)),
        );
      }
    } catch (e) {
      debugPrint('Delete Error: $e');
    }
  }

  // --- DIALOGS ---
  void _openEditDialog(Map<String, dynamic> record) {
    final nameCtrl = TextEditingController(text: record['name'] ?? '');
    final desigCtrl = TextEditingController(text: record['designation'] ?? '');
    final phoneCtrl = TextEditingController(text: record['phone'] ?? '');
    final salaryCtrl = TextEditingController(text: record['salary']?.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.edit_note, color: Color(0xFF4F46E5)),
            const SizedBox(width: 8),
            Text('Edit Record #${record['id']}', style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAdminInput(nameCtrl, 'Full Name', Icons.person_outline),
              const SizedBox(height: 12),
              _buildAdminInput(desigCtrl, 'Designation', Icons.badge_outlined),
              const SizedBox(height: 12),
              _buildAdminInput(phoneCtrl, 'Phone', Icons.phone_outlined, isPhone: true),
              const SizedBox(height: 12),
              _buildAdminInput(salaryCtrl, 'Salary (\$)', Icons.attach_money, isNumber: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final salary = double.tryParse(salaryCtrl.text.trim()) ?? 0.0;
              await _updateRecord(
                record['id'],
                nameCtrl.text.trim(),
                phoneCtrl.text.trim(),
                desigCtrl.text.trim(),
                salary,
              );
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Update Row'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDialog(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Deletion', style: TextStyle(color: Color(0xFFEF4444))),
        content: Text('Are you sure you want to permanently delete "$name" (ID: #$id) from the database?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await _deleteRecord(id);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminInput(TextEditingController controller, String label, IconData icon,
      {bool isPhone = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isPhone
          ? TextInputType.phone
          : (isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
      style: const TextStyle(color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF4F46E5)),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFF4F46E5), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Admin Database Console', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _fetchDatabaseRecords(query: _searchController.text),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STATS & SEARCH HEADER
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Color(0xFF0F172A)),
                    decoration: InputDecoration(
                      hintText: 'Filter table by name...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.5),
                      ),
                    ),
                    onChanged: (val) => _fetchDatabaseRecords(query: val),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    'Total Rows: ${_records.length}',
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 2. DATABASE TABLE VIEW
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
                    : _records.isEmpty
                    ? const Center(
                  child: Text('No database records found.', style: TextStyle(color: Color(0xFF64748B))),
                )
                    : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                      dataRowMinHeight: 52,
                      dataRowMaxHeight: 60,
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Designation', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Salary', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List<DataRow>.generate(_records.length, (index) {
                        final row = _records[index];
                        final isEven = index % 2 == 0;

                        return DataRow(
                          color: WidgetStateProperty.all(
                            isEven ? Colors.white : const Color(0xFFF8FAFC),
                          ),
                          cells: [
                            DataCell(Text('#${row['id']}', style: const TextStyle(color: Color(0xFF64748B)))),
                            DataCell(Text(row['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  row['designation'] ?? 'N/A',
                                  style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            DataCell(Text(row['phone'] ?? '')),
                            DataCell(Text('\$${row['salary'] ?? 0}')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF4F46E5), size: 20),
                                    tooltip: 'Edit Row',
                                    onPressed: () => _openEditDialog(row),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_forever, color: Color(0xFFEF4444), size: 20),
                                    tooltip: 'Delete Row',
                                    onPressed: () => _confirmDeleteDialog(row['id'], row['name'] ?? ''),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}