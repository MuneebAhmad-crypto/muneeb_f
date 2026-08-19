import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:study_mate/models/course.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/models/exam.dart';
import 'package:study_mate/models/schedule.dart';
import 'package:study_mate/models/quiz.dart';
import 'package:study_mate/core/services/local_cache_service.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;
  final LocalCacheService _cache = LocalCacheService();
  final Uuid _uuid = const Uuid();

  // Smart Network Diagnostic
  Future<bool> isNetworkBlocked() async {
    try {
      // Check if a neutral site is reachable
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        // Google works, now check Supabase
        try {
          final res = await http.get(Uri.parse('https://srtqadaxhitddbdgwzgg.supabase.co/health')).timeout(const Duration(seconds: 5));
          return res.statusCode != 200; // If google works but supabase doesn't respond 200, it's likely blocked.
        } catch (_) {
          return true; // Supabase unreachable but google is.
        }
      }
    } catch (_) {}
    return false; // General offline or unknown
  }

  // Network helper with ultra-fast failover for restricted WiFi
  Future<T> _fastRetry<T>(Future<T> Function() action, {int timeoutSecs = 10}) async {
    try {
      return await action().timeout(Duration(seconds: timeoutSecs));
    } catch (e) {
      final err = e.toString().toLowerCase();
      bool isReset = err.contains('connection reset') || 
                     err.contains('errno = 104') || 
                     err.contains('socketexception') ||
                     err.contains('authretryablefetchexception');
      
      if (isReset) {
        debugPrint('⚠️ WiFi Restriction Detected. Failing over to Cache.');
        throw 'NETWORK_RESTRICTED';
      }
      
      // One fast retry
      try {
        return await action().timeout(Duration(seconds: timeoutSecs));
      } catch (e2) {
        rethrow;
      }
    }
  }

  // AUTHENTICATION
  Future<AuthResponse> signIn(String email, String password) async {
    return await _fastRetry(() => client.auth.signInWithPassword(email: email, password: password));
  }

  Future<AuthResponse> signUp(
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
    String? avatarUrl;
    if (profilePicPath != null) {
      try {
        avatarUrl = await uploadAvatar(profilePicPath);
      } catch (e) {
        debugPrint('Avatar upload failed: $e');
      }
    }

    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name ?? '',
          'university': university ?? '',
          'reg_number': regNumber ?? '',
          'phone': phone ?? '',
          'program': program ?? '',
          'semester': semester ?? 1,
          'avatar_url': avatarUrl ?? '',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.user != null) {
        final profileData = {
          'id': response.user!.id,
          'email': email,
          'name': name,
          'university': university,
          'reg_number': regNumber,
          'phone': phone,
          'program': program,
          'semester': semester,
          'avatar_url': avatarUrl,
        };
        client.from('sm_profiles').upsert(profileData).then((_) => null).catchError((_) => null);
        await _cache.saveMap('sm_profile_cache', profileData);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await client.auth.signOut();
    await _cache.clearAll();
  }

  Future<AuthResponse> verifyOtp(String email, String token) async {
    return await _fastRetry(() => client.auth.verifyOTP(email: email, token: token, type: OtpType.signup));
  }

  Future<String?> uploadAvatar(String path) async {
    final file = File(path);
    final fileExt = path.split('.').last;
    final fileName = '${client.auth.currentUser?.id ?? _uuid.v4()}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';
    
    try {
      await client.storage.from('sm_avatars').upload(fileName, file);
      return client.storage.from('sm_avatars').getPublicUrl(fileName);
    } catch (e) {
      debugPrint('Storage Error: $e');
      return null;
    }
  }

  // PROFILES
  Future<Map<String, dynamic>?> getProfileFromCache() async {
    return await _cache.getMap('sm_profile_cache');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) return (await getProfileFromCache()) ?? {};
    
    try {
      final res = await _fastRetry(() => client.from('sm_profiles').select().eq('id', userId).single());
      final data = Map<String, dynamic>.from(res as Map);
      await _cache.saveMap('sm_profile_cache', data);
      return data;
    } catch (e) {
      return (await getProfileFromCache()) ?? {'name': 'Student', 'university': 'N/A'};
    }
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    final cached = await getProfileFromCache() ?? {};
    await _cache.saveMap('sm_profile_cache', {...cached, ...profile});

    try {
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        await client.from('sm_profiles').update(profile).eq('id', userId);
      }
    } catch (e) {
      debugPrint('updateProfile background sync failed: $e');
    }
  }

  // COURSES
  Future<List<Course>> getCoursesFromCache() async {
    final cached = await _cache.getList('sm_courses_cache');
    return cached.map((json) => Course.fromJson(json)).toList();
  }

  Future<List<Course>> getCourses() async {
    try {
      final response = await _fastRetry(() => client.from('sm_courses').select().order('created_at', ascending: false));
      final List rawList = response as List;
      final maps = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_courses_cache', maps);
      return maps.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      return await getCoursesFromCache();
    }
  }

  Future<void> addCourse(Course course) async {
    final data = course.toJson();
    final localId = data['id']?.isEmpty ?? true ? _uuid.v4() : data['id'];
    data['id'] = localId;
    data['user_id'] = client.auth.currentUser?.id;
    data['created_at'] = DateTime.now().toIso8601String();

    final cached = await _cache.getList('sm_courses_cache');
    cached.removeWhere((c) => c['id'] == localId);
    cached.insert(0, data);
    await _cache.saveList('sm_courses_cache', cached);

    try {
      await _fastRetry(() => client.from('sm_courses').insert(data));
    } catch (e) {
      debugPrint('addCourse sync failed: $e');
    }
  }

  Future<void> updateCourse(Course course) async {
    final cached = await _cache.getList('sm_courses_cache');
    final index = cached.indexWhere((c) => c['id'] == course.id);
    if (index != -1) {
      cached[index] = course.toJson();
      await _cache.saveList('sm_courses_cache', cached);
    }
    try {
      await client.from('sm_courses').update(course.toJson()).eq('id', course.id);
    } catch (e) {
      debugPrint('updateCourse remote error: $e');
    }
  }

  Future<void> deleteCourse(String id) async {
    final cached = await _cache.getList('sm_courses_cache');
    cached.removeWhere((c) => c['id'] == id);
    await _cache.saveList('sm_courses_cache', cached);

    try {
      await _fastRetry(() => client.from('sm_courses').delete().eq('id', id));
    } catch (e) {
      debugPrint('deleteCourse sync failed: $e');
    }
  }

  // ASSIGNMENTS
  Future<List<Assignment>> getAssignmentsFromCache() async {
    final cached = await _cache.getList('sm_assignments_cache');
    return cached.map((json) => Assignment.fromJson(json)).toList();
  }

  Future<List<Assignment>> getAssignments() async {
    try {
      final response = await _fastRetry(() => client.from('sm_assignments').select('*, sm_courses(name)').order('due_date', ascending: true));
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_assignments_cache', maps);
      return maps.map((json) => Assignment.fromJson(json)).toList();
    } catch (e) {
      return await getAssignmentsFromCache();
    }
  }

  Future<void> addAssignment(Assignment assignment) async {
    final userId = client.auth.currentUser?.id;
    final data = assignment.toJson();
    if (userId != null) data['user_id'] = userId;

    final cached = await _cache.getList('sm_assignments_cache');
    cached.insert(0, data);
    await _cache.saveList('sm_assignments_cache', cached);

    try {
      await _fastRetry(() => client.from('sm_assignments').insert(data));
    } catch (e) {
      debugPrint('addAssignment sync failed: $e');
    }
  }

  Future<void> updateAssignment(Assignment assignment) async {
    final cached = await _cache.getList('sm_assignments_cache');
    final index = cached.indexWhere((a) => a['id'] == assignment.id);
    if (index != -1) {
      cached[index] = assignment.toJson();
      await _cache.saveList('sm_assignments_cache', cached);
    }
    try {
      await client.from('sm_assignments').update(assignment.toJson()).eq('id', assignment.id);
    } catch (e) {
      debugPrint('updateAssignment remote error: $e');
    }
  }

  Future<void> deleteAssignment(String id) async {
    final cached = await _cache.getList('sm_assignments_cache');
    cached.removeWhere((a) => a['id'] == id);
    await _cache.saveList('sm_assignments_cache', cached);
    try {
      await _fastRetry(() => client.from('sm_assignments').delete().eq('id', id));
    } catch (e) {
      debugPrint('deleteAssignment remote error: $e');
    }
  }

  // EXAMS
  Future<List<Exam>> getExamsFromCache() async {
    final cached = await _cache.getList('sm_exams_cache');
    return cached.map((json) => Exam.fromJson(json)).toList();
  }

  Future<List<Exam>> getExams() async {
    try {
      final response = await _fastRetry(() => client.from('sm_exams').select('*, sm_courses(name)').order('date_time', ascending: true));
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_exams_cache', maps);
      return maps.map((json) => Exam.fromJson(json)).toList();
    } catch (e) {
      return await getExamsFromCache();
    }
  }

  Future<void> addExam(Exam exam) async {
    final userId = client.auth.currentUser?.id;
    final data = exam.toJson();
    if (userId != null) data['user_id'] = userId;

    final cached = await _cache.getList('sm_exams_cache');
    cached.insert(0, data);
    await _cache.saveList('sm_exams_cache', cached);

    try {
      await _fastRetry(() => client.from('sm_exams').insert(data));
    } catch (e) {
      debugPrint('addExam remote error: $e');
    }
  }

  Future<void> deleteExam(String id) async {
    final cached = await _cache.getList('sm_exams_cache');
    cached.removeWhere((e) => e['id'] == id);
    await _cache.saveList('sm_exams_cache', cached);
    try {
      await _fastRetry(() => client.from('sm_exams').delete().eq('id', id));
    } catch (e) {
      debugPrint('deleteExam remote error: $e');
    }
  }

  // SCHEDULES
  Future<List<Schedule>> getSchedulesFromCache() async {
    final cached = await _cache.getList('sm_schedules_cache');
    return cached.map((json) => Schedule.fromJson(json)).toList();
  }

  Future<List<Schedule>> getSchedules() async {
    try {
      final response = await _fastRetry(() => client.from('sm_class_schedules').select('*, sm_courses(name, code)'));
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_schedules_cache', maps);
      return maps.map((json) => Schedule.fromJson(json)).toList();
    } catch (e) {
      return await getSchedulesFromCache();
    }
  }

  Future<void> addSchedule(Schedule schedule) async {
    final userId = client.auth.currentUser?.id;
    final data = schedule.toJson();
    if (userId != null) data['user_id'] = userId;

    final cached = await _cache.getList('sm_schedules_cache');
    cached.add(data);
    await _cache.saveList('sm_schedules_cache', cached);

    try {
      await _fastRetry(() => client.from('sm_class_schedules').insert(data));
    } catch (e) {
      debugPrint('addSchedule remote error: $e');
    }
  }

  // ATTENDANCE
  Future<List<Map<String, dynamic>>> getAttendanceRecordsFromCache() async {
    return await _cache.getList('sm_attendance_cache');
  }

  Future<List<Map<String, dynamic>>> getAttendanceRecords() async {
    try {
      final response = await _fastRetry(() => client.from('sm_attendance_records').select());
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_attendance_cache', maps);
      return maps;
    } catch (e) {
      return await getAttendanceRecordsFromCache();
    }
  }

  Future<void> recordAttendance(String courseId, DateTime date, String status) async {
    final record = {
      'id': _uuid.v4(),
      'user_id': client.auth.currentUser?.id,
      'course_id': courseId,
      'date': date.toIso8601String().split('T')[0],
      'status': status,
    };

    final cached = await _cache.getList('sm_attendance_cache');
    cached.add(record);
    await _cache.saveList('sm_attendance_cache', cached);

    try {
      await client.from('sm_attendance_records').insert(record);
    } catch (e) {
      debugPrint('recordAttendance remote error: $e');
    }
  }

  // TASKS
  Future<List<Map<String, dynamic>>> getTasks() async {
    try {
      final response = await _fastRetry(() => client.from('sm_tasks').select().order('created_at', ascending: false));
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_tasks_cache', maps);
      return maps;
    } catch (e) {
      return await _cache.getList('sm_tasks_cache');
    }
  }

  Future<void> addTask(String title, DateTime? dueDate) async {
    final taskData = {
      'id': _uuid.v4(),
      'user_id': client.auth.currentUser?.id,
      'title': title,
      'is_completed': false,
      'due_date': dueDate?.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };

    final cached = await _cache.getList('sm_tasks_cache');
    cached.insert(0, taskData);
    await _cache.saveList('sm_tasks_cache', cached);

    try {
      await client.from('sm_tasks').insert(taskData);
    } catch (e) {
      debugPrint('addTask remote error: $e');
    }
  }

  // STUDY SESSIONS
  Future<void> saveStudySession(String? courseId, int durationMinutes, String type) async {
    try {
      await client.from('sm_study_sessions').insert({
        'user_id': client.auth.currentUser?.id,
        'course_id': courseId,
        'duration_minutes': durationMinutes,
        'session_type': type,
      });
    } catch (e) {
      debugPrint('saveStudySession remote error: $e');
    }
  }

  // QUIZZES
  Future<List<Quiz>> getQuizzesFromCache() async {
    final cached = await _cache.getList('sm_quizzes_cache');
    return cached.map((json) => Quiz.fromJson(json)).toList();
  }

  Future<List<Quiz>> getQuizzes() async {
    try {
      final response = await _fastRetry(() => client.from('sm_quizzes').select('*, sm_courses(name)'));
      final maps = (response as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
      await _cache.saveList('sm_quizzes_cache', maps);
      return maps.map((json) => Quiz.fromJson(json)).toList();
    } catch (e) {
      return await getQuizzesFromCache();
    }
  }

  Future<void> addQuiz(Quiz quiz) async {
    final data = quiz.toJson();
    if (client.auth.currentUser?.id != null) data['user_id'] = client.auth.currentUser?.id;

    final cached = await _cache.getList('sm_quizzes_cache');
    cached.insert(0, data);
    await _cache.saveList('sm_quizzes_cache', cached);

    try {
      await client.from('sm_quizzes').insert(data);
    } catch (e) {
      debugPrint('addQuiz remote error: $e');
    }
  }

  Future<void> deleteQuiz(String id) async {
    final cached = await _cache.getList('sm_quizzes_cache');
    cached.removeWhere((q) => q['id'] == id);
    await _cache.saveList('sm_quizzes_cache', cached);
    try {
      await _fastRetry(() => client.from('sm_quizzes').delete().eq('id', id));
    } catch (e) {
      debugPrint('deleteQuiz remote error: $e');
    }
  }
}
