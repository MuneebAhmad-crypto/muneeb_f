import 'package:flutter/material.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Schedule> _schedules = [];
  bool _isLoading = false;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _supabaseService.client.from('sm_class_schedules').select('*, sm_courses(name, code)');
      _schedules = response.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Schedule> getSchedulesForDay(String day) {
    return _schedules.where((s) => s.dayOfWeek == day).toList();
  }
}
