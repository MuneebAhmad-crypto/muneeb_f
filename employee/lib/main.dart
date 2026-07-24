import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://necbzbnfgzlyvtyrulro.supabase.co',
    anonKey: 'sb_publishable_aL7ifStDQyHmXgoOOlsscg_qGFlDjLY',
  );

  runApp(const CompanyApp());
}

final supabase = Supabase.instance.client;

class CompanyApp extends StatelessWidget {
  const CompanyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Company Directory',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
          centerTitle: false,
        ),
      ),
      home: const EmployeeDirectoryScreen(),
    );
  }
}

class EmployeeDirectoryScreen extends StatefulWidget {
  const EmployeeDirectoryScreen({super.key});

  @override
  State<EmployeeDirectoryScreen> createState() => _EmployeeDirectoryScreenState();
}

class _EmployeeDirectoryScreenState extends State<EmployeeDirectoryScreen> {
  // Input Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _desigController = TextEditingController();
  final _salaryController = TextEditingController();
  final _searchController = TextEditingController();

  List<Map<String, dynamic>> _employees = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _desigController.dispose();
    _salaryController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- SUPABASE CRUD ---
  Future<void> _fetchEmployees({String query = ''}) async {
    setState(() => _isLoading = true);
    try {
      final builder = supabase.from('employees').select();
      final response = query.isEmpty
          ? await builder.order('id', ascending: false)
          : await builder.ilike('name', '%$query%').order('id', ascending: false);

      setState(() {
        _employees = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Fetch Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addEmployee() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final designation = _desigController.text.trim();
    final salary = double.tryParse(_salaryController.text.trim()) ?? 0.0;

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least Name and Phone number')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await supabase.from('employees').insert({
        'name': name,
        'phone': phone,
        'designation': designation,
        'salary': salary,
      });

      // Clear input fields after successful save
      _nameController.clear();
      _phoneController.clear();
      _desigController.clear();
      _salaryController.clear();

      // Refresh list
      await _fetchEmployees(query: _searchController.text);
    } catch (e) {
      debugPrint('Insert Error: $e');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  // --- INPUT FIELD BUILDER ---
  Widget _buildInlineTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        bool isPhone = false,
        bool isNumber = false,
      }) {
    return TextField(
      controller: controller,
      keyboardType: isPhone
          ? TextInputType.phone
          : (isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
      style: const TextStyle(color: Color(0xFF0F172A)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2563EB), size: 20),
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Directory', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INPUT FORM CARD AT THE START
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add New Employee',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInlineTextField(_nameController, 'Employee Name', Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildInlineTextField(_desigController, 'Designation', Icons.badge_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInlineTextField(_phoneController, 'Phone', Icons.phone_outlined, isPhone: true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildInlineTextField(_salaryController, 'Salary', Icons.attach_money, isNumber: true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _isSaving ? null : _addEmployee,
                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                        : const Text('Save Employee', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. SEARCH BAR & SECTION HEADER
            const Text(
              'Employee Records',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              style: const TextStyle(color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Search records by name...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                ),
              ),
              onChanged: (val) => _fetchEmployees(query: val),
            ),

            const SizedBox(height: 14),

            // 3. RECORDS LIST AT THE END
            _isLoading
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
            )
                : _employees.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(
                child: Text('No employees found.', style: TextStyle(color: Color(0xFF64748B), fontSize: 15)),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final emp = _employees[index];
                final initial = (emp['name'] ?? 'E')[0].toUpperCase();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFEFF6FF),
                      child: Text(
                        initial,
                        style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    title: Text(
                      emp['name'] ?? '',
                      style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          emp['designation'] ?? '',
                          style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Text(
                          '${emp['phone']}  •  \$${emp['salary']}',
                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}