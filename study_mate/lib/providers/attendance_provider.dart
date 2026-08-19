import 'package:flutter/material.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, Map<String, int>> _stats = {}; // courseId -> {present, absent, total}
  bool _isLoading = false;

  Map<String, Map<String, int>> get stats => _stats;
  bool get isLoading => _isLoading;

  Future<void> fetchAttendance() async {
    _isLoading = true;
    
    try {
      final List records = await _supabaseService.getAttendanceRecords();
      Map<String, Map<String, int>> newStats = {};
      for (var r in records) {
        final cid = r['course_id'];
        final status = r['status'];
        if (!newStats.containsKey(cid)) {
          newStats[cid] = {'present': 0, 'absent': 0, 'total': 0};
        }
        newStats[cid]!['total'] = (newStats[cid]!['total'] ?? 0) + 1;
        if (status == 'present') {
          newStats[cid]!['present'] = (newStats[cid]!['present'] ?? 0) + 1;
        } else {
          newStats[cid]!['absent'] = (newStats[cid]!['absent'] ?? 0) + 1;
        }
      }
      _stats = newStats;
    } catch (e) {
      debugPrint('Error fetching attendance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAttendance(String courseId, String status) async {
    // Optimistic UI Update
    if (!_stats.containsKey(courseId)) {
      _stats[courseId] = {'present': 0, 'absent': 0, 'total': 0};
    }
    _stats[courseId]!['total'] = (_stats[courseId]!['total'] ?? 0) + 1;
    if (status == 'present') {
      _stats[courseId]!['present'] = (_stats[courseId]!['present'] ?? 0) + 1;
    } else {
      _stats[courseId]!['absent'] = (_stats[courseId]!['absent'] ?? 0) + 1;
    }
    notifyListeners();

    try {
      await _supabaseService.recordAttendance(courseId, DateTime.now(), status);
    } catch (e) {
      debugPrint('Error marking attendance: $e');
    }
  }
}
