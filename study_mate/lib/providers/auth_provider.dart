import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_mate/core/services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initAuthListener();
  }

  void _initAuthListener() {
    _user = _supabaseService.client.auth.currentUser;
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    }, onError: (e) {
      debugPrint('Auth State Change Error: $e');
      if (e.toString().contains('Connection reset by peer')) {
        // If the connection is resetting during background refresh, 
        // we might need to handle a logout or a retry.
      }
    });
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _supabaseService.signIn(email, password);
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Connection reset by peer') || 
          errorMessage.contains('SocketException') ||
          errorMessage.contains('AuthRetryableFetchException')) {
        _error = 'Network error: Connection reset by peer. This usually happens when your ISP or WiFi blocks Supabase. \n\nPLEASE TRY:\n1. Switch to Mobile Data\n2. Use a VPN\n3. Try a different WiFi';
      } else if (errorMessage.contains('Email not confirmed')) {
        _error = 'Please verify your email before logging in.';
      } else {
        _error = errorMessage;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(
    String email, 
    String password, {
    String? name,
    String? university,
    String? regNumber,
    String? phone,
    String? program,
    int? semester,
    String? profilePicPath,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _supabaseService.signUp(
        email, 
        password, 
        name: name,
        university: university,
        regNumber: regNumber,
        phone: phone,
        program: program,
        semester: semester,
        profilePicPath: profilePicPath,
      );
      
      // If session is returned immediately, no OTP is needed (confirmed by default)
      if (response.session != null) {
        _user = response.session!.user;
      }
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Connection reset by peer') || 
          errorMessage.contains('SocketException') ||
          errorMessage.contains('AuthRetryableFetchException')) {
        _error = 'Network error: Connection reset by peer. This usually happens when your ISP or WiFi blocks Supabase. \n\nPLEASE TRY:\n1. Switch to Mobile Data\n2. Use a VPN\n3. Try a different WiFi';
      } else if (errorMessage.contains('Email not confirmed')) {
        _error = 'Please verify your email before logging in.';
      } else {
        _error = errorMessage;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
  }

  Future<bool> verifyOtp(String email, String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _supabaseService.verifyOtp(email, token);
      return true;
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Connection reset by peer') || 
          errorMessage.contains('SocketException') ||
          errorMessage.contains('AuthRetryableFetchException')) {
        _error = 'Network error: Connection reset by peer. This usually happens when your ISP or WiFi blocks Supabase. \n\nPLEASE TRY:\n1. Switch to Mobile Data\n2. Use a VPN\n3. Try a different WiFi';
      } else if (errorMessage.contains('Email not confirmed')) {
        _error = 'Please verify your email before logging in.';
      } else {
        _error = errorMessage;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
