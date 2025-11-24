import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'env_service.dart';

class MealPlanService {
  static String get _baseUrl => EnvService.apiBaseUrl;

  static Future<Map<String, dynamic>?> generateForUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/mealplan/generate');

    final res = await http.post(url, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    developer.log('Failed to generate meal plan: ${res.statusCode} ${res.body}');
    return null;
  }
}
