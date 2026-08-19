import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accNoController = TextEditingController();
  final _accHolderController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      final data = await _supabase.from('profiles').select().eq('id', user!.id).single();
      
      _nameController.text = data['full_name'] ?? '';
      _companyController.text = data['company_name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _addressController.text = data['address'] ?? '';
      _taxIdController.text = data['tax_id'] ?? '';
      _bankNameController.text = data['bank_name'] ?? '';
      _accNoController.text = data['account_number'] ?? '';
      _accHolderController.text = data['account_holder'] ?? '';
    } catch (e) {
      // Empty profile
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      await _supabase.from('profiles').upsert({
        'id': user!.id,
        'full_name': _nameController.text,
        'company_name': _companyController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'tax_id': _taxIdController.text,
        'bank_name': _bankNameController.text,
        'account_number': _accNoController.text,
        'account_holder': _accHolderController.text,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A237E);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Settings'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () => _supabase.auth.signOut())],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionTitle('COMPANY DETAILS'),
                  const SizedBox(height: 16),
                  _buildTextField(_nameController, 'Your Name', Icons.person_outline),
                  _buildTextField(_companyController, 'Company Name', Icons.business_outlined),
                  _buildTextField(_taxIdController, 'Tax ID / VAT / GST', Icons.tag),
                  _buildTextField(_phoneController, 'Phone', Icons.phone_outlined),
                  _buildTextField(_addressController, 'Address', Icons.location_on_outlined, maxLines: 2),
                  
                  const SizedBox(height: 32),
                  _sectionTitle('BANK DETAILS (FOR PAYMENTS)'),
                  const SizedBox(height: 16),
                  _buildTextField(_bankNameController, 'Bank Name', Icons.account_balance_outlined),
                  _buildTextField(_accNoController, 'Account Number / IBAN', Icons.numbers),
                  _buildTextField(_accHolderController, 'Account Holder Name', Icons.badge_outlined),
                  
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('SAVE BUSINESS PROFILE', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2));

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}
