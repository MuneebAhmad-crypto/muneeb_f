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
    notifyListeners();
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
    try {
      await _supabaseService.updateProfile(data);
      _profile = {...?_profile, ...data};
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating profile: $e');
    }
  }
}
