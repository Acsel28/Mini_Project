import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_model.dart';

class MealLoggingService {
  static String _keyFor(String userId, DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    final dayKey = normalized.toIso8601String().split('T').first;
    return 'meal_log::$userId::$dayKey';
  }

  static Future<MealPlan?> loadLoggedPlan(String userId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = DateTime(date.year, date.month, date.day);
    final raw = prefs.getString(_keyFor(userId, normalized));
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return MealPlan.fromJson(raw);
  }

  static Future<void> saveLoggedPlan(String userId, MealPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = DateTime(plan.date.year, plan.date.month, plan.date.day);
    await prefs.setString(_keyFor(userId, normalized), plan.toJson());
  }

  static Future<void> clearLoggedPlan(String userId, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = DateTime(date.year, date.month, date.day);
    await prefs.remove(_keyFor(userId, normalized));
  }
}
