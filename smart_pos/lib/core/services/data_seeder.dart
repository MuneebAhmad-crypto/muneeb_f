import 'package:flutter/foundation.dart';
import '../../data/local/database_helper.dart';

class DataSeeder {
  static final DataSeeder _instance = DataSeeder._internal();
  factory DataSeeder() => _instance;
  DataSeeder._internal();

  final _db = DatabaseHelper();

  // Seeding disabled for live production - ensures 0 stock on fresh run
  Future<void> seedDefaultData({String? userId}) async {
    debugPrint('[DataSeeder] Live mode: Seeding skipped');
    return;
  }

  Future<void> seedAdminUser() async {
    return;
  }

  Future<void> seedCategories({String? userId}) async {
    return;
  }

  Future<void> seedProducts({String? userId}) async {
    return;
  }

  Future<void> forceReseed({String? userId}) async {
    return;
  }

  Future<void> ensureCategories({String? userId}) async {
    return;
  }

  Future<void> addMobileShopData({String? userId}) async {
    return;
  }

  // Utility to clear everything for a fresh start (one-time use)
  Future<void> clearAllLocalData() async {
    try {
      await _db.clearAllData();
      debugPrint('[DataSeeder] ALL LOCAL DATA WIPED FOR LIVE START');
    } catch (e) {
      debugPrint('[DataSeeder] Error wiping data: $e');
    }
  }
}
