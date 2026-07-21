import 'package:supabase_flutter/supabase_flutter.dart';
import 'calculation.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // CREATE
  Future<void> addCalculation(String expression, String result) async {
    await _client.from('calculations').insert({
      'expression': expression,
      'result': result,
    });
  }

  // READ
  Future<List<Calculation>> getHistory() async {
    final response = await _client
        .from('calculations')
        .select()
        .order('id', ascending: false);

    return (response as List)
        .map((data) => Calculation.fromJson(data))
        .toList();
  }

  // DELETE SINGLE
  Future<void> deleteCalculation(int id) async {
    await _client.from('calculations').delete().eq('id', id);
  }

  // DELETE ALL
  Future<void> clearHistory() async {
    await _client.from('calculations').delete().neq('id', 0);
  }
}