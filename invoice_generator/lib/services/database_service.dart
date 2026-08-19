import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/invoice_model.dart';

class DatabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {};
    
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      return data;
    } catch (e) {
      return {};
    }
  }

  Future<List<Invoice>> getInvoices() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _supabase
        .from('invoices')
        .select('*, invoice_items(*)')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((invoiceJson) {
      final itemsJson = invoiceJson['invoice_items'] as List;
      final items = itemsJson.map((i) => InvoiceItem.fromJson(i)).toList();
      return Invoice.fromJson(invoiceJson, items);
    }).toList();
  }

  Future<void> createInvoice(Invoice invoice) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    final invoiceData = invoice.toJson();
    final insertedInvoice = await _supabase.from('invoices').insert(invoiceData).select().single();

    final invoiceId = insertedInvoice['id'];
    final itemsData = invoice.items.map((item) {
      final data = item.toJson();
      data['invoice_id'] = invoiceId;
      return data;
    }).toList();

    await _supabase.from('invoice_items').insert(itemsData);
  }

  Future<void> deleteInvoice(String id) async {
    await _supabase.from('invoices').delete().eq('id', id);
  }
}
