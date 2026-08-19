import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final Uuid _uuid = const Uuid();
  List<Schedule> _schedules = [];
  bool _isLoading = false;

  List<Schedule> get schedules => _schedules;
  bool get isLoading => _isLoading;

  Future<void> fetchSchedules() async {
    _isLoading = true;
    
    // 1. Load from cache
    try {
      final cached = await _supabaseService.getSchedulesFromCache();
      if (cached.isNotEmpty) {
        _schedules = cached;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    // 2. Fetch from remote
    try {
      _schedules = await _supabaseService.getSchedules();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Schedule> getSchedulesForDay(String day) {
    // Robust comparison: handle casing and potential spaces
    final normalizedDay = day.trim().toLowerCase();
    return _schedules.where((s) => s.dayOfWeek.trim().toLowerCase() == normalizedDay).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    final validUuid = (schedule.id.isNotEmpty && schedule.id.contains('-')) ? schedule.id : _uuid.v4();
    final newSchedule = Schedule(
      id: validUuid,
      courseId: schedule.courseId,
      dayOfWeek: schedule.dayOfWeek,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      room: schedule.room,
      courseName: schedule.courseName,
      courseCode: schedule.courseCode,
    );

    _schedules.add(newSchedule);
    notifyListeners();

    try {
      await _supabaseService.addSchedule(newSchedule);
    } catch (_) {}
  }
}
