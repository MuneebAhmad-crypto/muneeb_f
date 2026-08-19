import 'package:flutter/material.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class ProfileProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  Map<String, dynamic>? _profile;
  bool _isLoading = false;

  Map<String, dynamic>? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    _isLoading = true;
    
    // 1. Load from cache immediately
    try {
      final cached = await _supabaseService.getProfileFromCache();
      if (cached != null) {
        _profile = cached;
        _isLoading = false;
        notifyListeners();
      }
    } catch (_) {}

    // 2. Fetch from remote
    try {
      _profile = await _supabaseService.getProfile();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    // 1. Instant local update
    _profile = {...?_profile, ...data};
    notifyListeners();

    // 2. Background sync
    _supabaseService.updateProfile(data).catchError((e) {
      debugPrint('Error updating profile in background: $e');
    });
  }
}
