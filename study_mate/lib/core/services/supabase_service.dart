import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:study_mate/models/course.dart';
import 'package:study_mate/models/assignment.dart';
import 'package:study_mate/models/exam.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  // Authentication
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, {String? name}) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Courses
  Future<List<Course>> getCourses() async {
    final response = await client.from('sm_courses').select();
    return response.map((json) => Course.fromJson(json)).toList();
  }

  Future<void> addCourse(Course course) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    final data = course.toJson();
    data['user_id'] = userId;
    await client.from('sm_courses').insert(data);
  }

  // Assignments
  Future<List<Assignment>> getAssignments() async {
    final response = await client.from('sm_assignments').select('*, sm_courses(name)');
    return response.map((json) => Assignment.fromJson(json)).toList();
  }

  // Exams
  Future<List<Exam>> getExams() async {
    final response = await client.from('sm_exams').select('*, sm_courses(name)');
    return response.map((json) => Exam.fromJson(json)).toList();
  }

  // Profiles
  Future<Map<String, dynamic>> getProfile() async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    final response = await client.from('sm_profiles').select().eq('id', userId).single();
    return response;
  }

  Future<void> updateProfile(Map<String, dynamic> profile) async {
    final userId = client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');
    
    await client.from('sm_profiles').update(profile).eq('id', userId);
  }
}
