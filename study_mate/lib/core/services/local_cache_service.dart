import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  // Save list of JSON maps to cache
  Future<void> saveList(String key, List<Map<String, dynamic>> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(items);
      await prefs.setString(key, jsonString);
    } catch (e) {
      // Ignore cache write errors
    }
  }

  // Read list of JSON maps from cache
  Future<List<Map<String, dynamic>>> getList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List decoded = jsonDecode(jsonString);
        return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
      }
    } catch (e) {
      // Ignore cache read errors
    }
    return [];
  }

  // Save single JSON map
  Future<void> saveMap(String key, Map<String, dynamic> item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(item);
      await prefs.setString(key, jsonString);
    } catch (e) {
      // Ignore
    }
  }

  // Get single JSON map
  Future<Map<String, dynamic>?> getMap(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(key);
      if (jsonString != null && jsonString.isNotEmpty) {
        return Map<String, dynamic>.from(jsonDecode(jsonString) as Map);
      }
    } catch (e) {
      // Ignore
    }
    return null;
  }

  // Clear all cached data (used on logout)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      // Ignore
    }
  }
}
