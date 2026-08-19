import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _clientNameController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _taxController = TextEditingController(text: '0');
  final _shippingController = TextEditingController(text: '0');
  final _notesController = TextEditingController();
  
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  final List<InvoiceItem> _items = [];
  final _dbService = DatabaseService();
  bool _isSaving = false;

  void _addItem() {
    setState(() => _items.add(InvoiceItem(description: '', quantity: 1, unitPrice: 0.0, total: 0.0)));
  }

  void _removeItem(int index) => setState(() => _items.removeAt(index));

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _discount => double.tryParse(_discountController.text) ?? 0;
  double get _taxRate => double.tryParse(_taxController.text) ?? 0;
  double get _shipping => double.tryParse(_shippingController.text) ?? 0;
  
  double get _taxAmount => (_subtotal - _discount) * (_taxRate / 100);
  double get _total => (_subtotal - _discount) + _taxAmount + _shipping;

  Future<void> _selectDate(BuildContext context, bool isDueDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDueDate ? (_dueDate ?? DateTime.now().add(const Duration(days: 7))) : _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) _dueDate = picked;
        else _invoiceDate = picked;
      });
    }
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add at least one item and fill client name')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      final invoice = Invoice(
        userId: user!.id,
        clientName: _clientNameController.text,
        clientEmail: _clientEmailController.text,
        clientAddress: _clientAddressController.text,
        invoiceDate: _invoiceDate,
        dueDate: _dueDate,
        totalAmount: _subtotal,
        discount: _discount,
        taxPercentage: _taxRate,
        shippingCharges: _shipping,
        notes: _notesController.text,
        items: _items,
      );

      await _dbService.createInvoice(invoice);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF1A237E);

    return Scaffold(
      appBar: AppBar(title: const Text('New Professional Invoice')),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionHeader('DATES & TERMS'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _dateTile('Invoice Date', _invoiceDate, () => _selectDate(context, false)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _dateTile('Due Date', _dueDate, () => _selectDate(context, true)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader('CLIENT INFORMATION'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientNameController,
                      decoration: const InputDecoration(labelText: 'Client Name', prefixIcon: Icon(Icons.person_outline)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _clientAddressController,
                      decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on_outlined)),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sectionHeader('INVOICE ITEMS'),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add_circle_outline, color: primaryColor),
                          label: const Text('Add Item', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 0,
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey[200]!)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextFormField(
                                  decoration: const InputDecoration(labelText: 'Description', isDense: true, fillColor: Colors.white),
                                  onChanged: (v) => _items[index] = InvoiceItem(
                                    description: v,
                                    quantity: _items[index].quantity,
                                    unitPrice: _items[index].unitPrice,
                                    total: _items[index].total,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(labelText: 'Qty', isDense: true, fillColor: Colors.white),
                                        keyboardType: TextInputType.number,
                                        initialValue: '1',
                                        onChanged: (v) {
                                          final q = int.tryParse(v) ?? 0;
                                          setState(() => _items[index] = InvoiceItem(
                                            description: _items[index].description,
                                            quantity: q,
                                            unitPrice: _items[index].unitPrice,
                                            total: q * _items[index].unitPrice,
                                          ));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextFormField(
                                        decoration: const InputDecoration(labelText: 'Price', isDense: true, fillColor: Colors.white),
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) {
                                          final p = double.tryParse(v) ?? 0;
                                          setState(() => _items[index] = InvoiceItem(
                                            description: _items[index].description,
                                            quantity: _items[index].quantity,
                                            unitPrice: p,
                                            total: _items[index].quantity * p,
                                          ));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: () => _removeItem(index), 
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      style: IconButton.styleFrom(backgroundColor: Colors.red[50]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    _sectionHeader('ADDITIONAL COSTS'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _costInput('Tax (%)', _taxController)),
                        const SizedBox(width: 12),
                        Expanded(child: _costInput('Shipping', _shippingController)),
                        const SizedBox(width: 12),
                        Expanded(child: _costInput('Discount', _discountController)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _sectionHeader('NOTES'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Add payment terms, bank details or a thank you note...', fillColor: Colors.white),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          // Highly visible sticky button at the bottom
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('GRAND TOTAL', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        Text('\$${_total.toStringAsFixed(2)}', 
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveInvoice,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00BFA5), // Vibrant Teal for high visibility
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 4,
                        shadowColor: const Color(0xFF00BFA5).withOpacity(0.5),
                      ),
                      child: _isSaving 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('SAVE & SEND', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 11, letterSpacing: 1.2));

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(date == null ? 'Select Date' : DateFormat('dd MMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _costInput(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(labelText: label, isDense: true, fillColor: Colors.white),
      onChanged: (v) => setState(() {}),
    );
  }
}
