// lib/services/exercise_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_service.dart';

class ExerciseService {
  /// Calls POST /api/exercises/plan on your Node backend.
  /// If [condition] is null, backend uses user's disease_profile_id or 'general'.
  static Future<Map<String, dynamic>> getExercisePlan({
    String? condition,
    String? customCondition,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('${AuthService.baseUrl}/api/exercises/plan');

    final body = <String, dynamic>{};
    if (condition != null && condition.isNotEmpty) {
      body['condition'] = condition;
    }
    if (customCondition != null && customCondition.isNotEmpty) {
      body['customCondition'] = customCondition;
    }

    final res = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load exercise plan: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map) {
      throw Exception('Invalid exercise plan format');
    }

    return Map<String, dynamic>.from(decoded);
  }
}
