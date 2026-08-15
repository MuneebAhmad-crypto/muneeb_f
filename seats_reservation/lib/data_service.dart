import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'models.dart';
import 'notifier.dart';

class DataService extends ChangeNotifier {
  static const String supabaseUrl = 'https://necbzbnfgzlyvtyrulro.supabase.co';
  static const String supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5lY2J6Ym5mZ3pseXZ0eXJ1bHJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ1NDAwNDcsImV4cCI6MjEwMDExNjA0N30.xNkrQWkCrdHEv3YjtrgWHKFX66VBYH77fS1bON0krts';
  
  final _supabase = Supabase.instance.client;

  UserAccount? _currentUser;
  List<UserAccount> _allUsers = [];
  List<BookingEntry> _reservations = [];
  int _totalSeats = 20;
  int _defaultFineAmount = 50;
  
  TimeOfDay _officeReservationStartTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _officeReservationEndTime = const TimeOfDay(hour: 10, minute: 0);
  
  TimeOfDay _attendanceStartTime = const TimeOfDay(hour: 11, minute: 0);
  
  TimeOfDay _remoteStartTime = const TimeOfDay(hour: 14, minute: 0);
  TimeOfDay _remoteEndTime = const TimeOfDay(hour: 17, minute: 0);
  
  bool _isLoading = false;

  UserAccount? get currentUser => _currentUser;
  List<UserAccount> get users => _allUsers;
  List<BookingEntry> get reservations => _reservations;
  int get totalSeats => _totalSeats;
  int get defaultFineAmount => _defaultFineAmount;
  
  TimeOfDay get officeReservationStartTime => _officeReservationStartTime;
  TimeOfDay get officeReservationEndTime => _officeReservationEndTime;
  TimeOfDay get attendanceStartTime => _attendanceStartTime;
  TimeOfDay get remoteStartTime => _remoteStartTime;
  TimeOfDay get remoteEndTime => _remoteEndTime;
  bool get isLoading => _isLoading;

  DataService() {
    _init();
  }

  Future<void> _init() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserData(session.user.id);
      _listenToChanges();
    }
    await _loadSettings();
  }

  void _listenToChanges() {
    _supabase.from('profiles').stream(primaryKey: ['id']).listen((data) {
      final newUsers = data.map((json) => _mapUser(json)).toList();
      
      if (_currentUser != null) {
        final updatedMe = newUsers.where((u) => u.id == _currentUser!.id).firstOrNull;
        if (updatedMe != null && updatedMe.fineAmount > _currentUser!.fineAmount) {
          AppNotifier.showFineAlert(updatedMe.fineAmount - _currentUser!.fineAmount);
        }
      }

      _allUsers = newUsers;
      if (_currentUser != null) {
        final updatedMe = _allUsers.where((u) => u.id == _currentUser!.id);
        if (updatedMe.isNotEmpty) _currentUser = updatedMe.first;
      }
      notifyListeners();
    });

    _supabase.from('reservations').stream(primaryKey: ['id']).listen((data) {
      _reservations = data.map((json) => _mapReservation(json)).toList();
      notifyListeners();
    });

    _supabase.from('settings').stream(primaryKey: ['key']).listen((data) {
      for (var row in data) {
        if (row['key'] == 'total_seats') _totalSeats = int.tryParse(row['value'].toString()) ?? 20;
        if (row['key'] == 'default_fine_amount') _defaultFineAmount = int.tryParse(row['value'].toString()) ?? 50;
        
        if (row['key'] == 'office_reservation_start') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _officeReservationStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'office_reservation_end') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _officeReservationEndTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'attendance_start_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _attendanceStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'remote_start_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _remoteStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'remote_end_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _remoteEndTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      notifyListeners();
    });
  }

  UserAccount _mapUser(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.student,
      isApproved: json['is_approved'] ?? false,
      fineAmount: json['fine_amount'] ?? 0,
    );
  }

  BookingEntry _mapReservation(Map<String, dynamic> json) {
    return BookingEntry(
      userId: json['user_id'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toString()),
      category: json['reservation_type'] ?? 'office',
      isApproved: json['is_approved'] ?? false,
      showedUp: json['showed_up'] ?? false,
      isFinalized: json['is_finalized'] ?? false,
    );
  }

  Future<void> _loadSettings() async {
    try {
      final res = await _supabase.from('settings').select();
      for (var row in res) {
        if (row['key'] == 'total_seats') _totalSeats = int.tryParse(row['value'].toString()) ?? 20;
        if (row['key'] == 'default_fine_amount') _defaultFineAmount = int.tryParse(row['value'].toString()) ?? 50;
        
        if (row['key'] == 'office_reservation_start') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _officeReservationStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'office_reservation_end') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _officeReservationEndTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'attendance_start_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _attendanceStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'remote_start_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _remoteStartTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
        if (row['key'] == 'remote_end_time') {
          final parts = row['value'].toString().split(':');
          if (parts.length == 2) _remoteEndTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final data = await _supabase.from('profiles').select().eq('id', userId).single();
      _currentUser = _mapUser(data);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<String?> login(String identifier, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      String email = identifier;
      if (!identifier.contains('@')) {
        final profile = await _supabase
            .from('profiles')
            .select('email')
            .eq('phone', identifier)
            .maybeSingle();
        
        if (profile == null) return 'Phone number not registered';
        email = profile['email'];
      }

      final res = await _supabase.auth.signInWithPassword(email: email, password: password);
      if (res.user != null) {
        await _loadUserData(res.user!.id);
        _listenToChanges();
        return null;
      }
      return 'Login failed';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> register(String name, String email, String phone, String password, UserRole role) async {
    try {
      _isLoading = true;
      notifyListeners();
      final res = await _supabase.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await _supabase.from('profiles').insert({
          'id': res.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': role == UserRole.admin ? 'admin' : 'student',
          'is_approved': role == UserRole.admin,
          'fine_amount': 0,
        });
        return null;
      }
      return 'Registration failed';
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    _allUsers = [];
    _reservations = [];
    notifyListeners();
  }

  // Admin Actions
  Future<String?> setTotalSeats(int count) async {
    try {
      await _supabase.from('settings').upsert({'key': 'total_seats', 'value': count.toString()});
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> setDefaultFineAmount(int amount) async {
    try {
      await _supabase.from('settings').upsert({'key': 'default_fine_amount', 'value': amount.toString()});
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> setOfficeReservationTimes(TimeOfDay start, TimeOfDay end) async {
    try {
      await _supabase.from('settings').upsert({'key': 'office_reservation_start', 'value': '${start.hour}:${start.minute}'});
      await _supabase.from('settings').upsert({'key': 'office_reservation_end', 'value': '${end.hour}:${end.minute}'});
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> setAttendanceStartTime(TimeOfDay time) async {
    try {
      final value = '${time.hour}:${time.minute}';
      await _supabase.from('settings').upsert({'key': 'attendance_start_time', 'value': value});
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> setRemoteTimes(TimeOfDay start, TimeOfDay end) async {
    try {
      await _supabase.from('settings').upsert({'key': 'remote_start_time', 'value': '${start.hour}:${start.minute}'});
      await _supabase.from('settings').upsert({'key': 'remote_end_time', 'value': '${end.hour}:${end.minute}'});
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> approveStudent(String userId) async {
    try {
      await _supabase.from('profiles').update({'is_approved': true}).eq('id', userId);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> updateFineAmount(String userId, int newAmount) async {
    try {
      await _supabase.from('profiles').update({'fine_amount': newAmount}).eq('id', userId);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> approveReservation(String userId, DateTime date) async {
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      await _supabase.from('reservations').update({'is_approved': true}).eq('user_id', userId).eq('date', dateStr);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> promoteToAdmin(String userId) async {
    try {
      await _supabase.from('profiles').update({'role': 'admin', 'is_approved': true}).eq('id', userId);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> deleteUserAccount(String userId) async {
    try {
      await _supabase.from('profiles').delete().eq('id', userId);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> resetTodayBookings() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      await _supabase.from('reservations').delete().eq('date', today);
      return null;
    } catch (e) { return e.toString(); }
  }

  Future<String?> createSecondaryAdmin(String name, String email, String phone, String password) async {
    try {
      // Use a temporary client with no-op storage to avoid PKCE storage assertions
      // and prevent the current admin from being logged out.
      final tempClient = SupabaseClient(
        supabaseUrl, 
        supabaseKey,
        authOptions: const AuthClientOptions(
          authFlowType: AuthFlowType.implicit,
        ),
      );
      
      final res = await tempClient.auth.signUp(email: email, password: password);
      if (res.user != null) {
        await _supabase.from('profiles').insert({
          'id': res.user!.id,
          'name': name,
          'email': email,
          'phone': phone,
          'role': 'admin',
          'is_approved': true,
          'fine_amount': 0,
        });
        return null;
      }
      return 'Creation failed';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> finalizeRemoteSection() async {
    try {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      
      final pendingRemote = _reservations.where((r) => 
        r.category == 'remote' && 
        DateFormat('yyyy-MM-dd').format(r.date) == today && 
        !r.showedUp && 
        !r.isFinalized
      ).toList();

      for (var res in pendingRemote) {
        await _supabase.from('reservations').update({
          'is_finalized': true,
          'showed_up': false
        }).eq('user_id', res.userId).eq('date', today);

        final user = _allUsers.firstWhere((u) => u.id == res.userId);
        await _supabase.from('profiles').update({
          'fine_amount': user.fineAmount + _defaultFineAmount
        }).eq('id', res.userId);
      }
      return null;
    } catch (e) { return e.toString(); }
  }

  // Student Actions
  Future<String?> reserveSeat({bool isRemote = false}) async {
    try {
      if (_currentUser == null) return 'Login required';
      if (!_currentUser!.isApproved) return 'Account pending admin approval';

      final now = DateTime.now();
      
      if (!isRemote) {
        final start = DateTime(now.year, now.month, now.day, _officeReservationStartTime.hour, _officeReservationStartTime.minute);
        final end = DateTime(now.year, now.month, now.day, _officeReservationEndTime.hour, _officeReservationEndTime.minute);
        
        if (now.isBefore(start)) return 'Reservation starts at ${_formatTimeOfDay(_officeReservationStartTime)}';
        if (now.isAfter(end)) return 'Reservation ended at ${_formatTimeOfDay(_officeReservationEndTime)}';
      } else {
        final deadline = DateTime(now.year, now.month, now.day, _remoteEndTime.hour, _remoteEndTime.minute);
        if (now.isAfter(deadline)) return 'Remote registration ended at ${_formatTimeOfDay(_remoteEndTime)}';
      }

      final dateStr = DateFormat('yyyy-MM-dd').format(now);
      final existing = await _supabase.from('reservations')
          .select()
          .eq('user_id', _currentUser!.id)
          .eq('date', dateStr);
      
      if (existing.isNotEmpty) return 'You already have a booking for today';

      if (!isRemote) {
        final countRes = await _supabase.from('reservations')
            .select()
            .eq('date', dateStr)
            .eq('reservation_type', 'office');
        if (countRes.length >= _totalSeats) return 'No physical seats available';
      }

      await _supabase.from('reservations').insert({
        'user_id': _currentUser!.id,
        'date': dateStr,
        'showed_up': false,
        'is_approved': false,
        'reservation_type': isRemote ? 'remote' : 'office',
      });
      return null;
    } catch (e) {
      debugPrint('Error in reserveSeat: $e');
      return 'Database error: Check if all columns exist';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<String?> markAttendance(String userId, DateTime date, bool showedUp) async {
    try {
      final now = DateTime.now();
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      
      final currentRes = _reservations.firstWhere(
        (r) => r.userId == userId && DateFormat('yyyy-MM-dd').format(r.date) == dateStr,
        orElse: () => BookingEntry(
          userId: userId, 
          date: date, 
          category: 'office',
          isApproved: false,
          showedUp: false,
          isFinalized: false
        )
      );

      if (currentRes.isFinalized) return 'Attendance already finalized for this student.';

      if (currentRes.category == 'office') {
        final startTime = DateTime(now.year, now.month, now.day, _attendanceStartTime.hour, _attendanceStartTime.minute);
        if (now.isBefore(startTime)) return 'Attendance starts at ${_formatTimeOfDay(_attendanceStartTime)}';
      } else {
        final startTime = DateTime(now.year, now.month, now.day, _remoteStartTime.hour, _remoteStartTime.minute);
        final endTime = DateTime(now.year, now.month, now.day, _remoteEndTime.hour, _remoteEndTime.minute);
        
        if (now.isBefore(startTime)) return 'Remote section starts at ${_formatTimeOfDay(_remoteStartTime)}';
        if (now.isAfter(endTime)) return 'Remote section has ended.';
      }

      await _supabase.from('reservations').update({
        'showed_up': showedUp,
        'is_finalized': true
      }).eq('user_id', userId).eq('date', dateStr);
      
      if (!showedUp) {
        final user = _allUsers.firstWhere((u) => u.id == userId);
        await _supabase.from('profiles').update({'fine_amount': user.fineAmount + _defaultFineAmount}).eq('id', userId);
      }
      return null;
    } catch (e) { return e.toString(); }
  }
}
