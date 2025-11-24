import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'env_service.dart';

class AnalyticsService {
  static String get _baseUrl => '${EnvService.apiBaseUrl}/api/analytics';

  static Future<Map<String, dynamic>?> getUserStats() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/user-stats'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error fetching user stats: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getRecommendations() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['recommendations'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error fetching recommendations: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getMealSuggestions({
    String mealType = 'breakfast',
    int count = 5,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/meal-suggestions?mealType=$mealType&count=$count'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error fetching meal suggestions: $e');
      return null;
    }
  }

  static Future<List<dynamic>?> getHealthInsights() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/health-insights'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['insights'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error fetching health insights: $e');
      return null;
    }
  }

  static Future<bool> saveCoachResponse({
    required int questionId,
    required String selectedOption,
    required String answer,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/coach-response'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'questionId': questionId,
          'selectedOption': selectedOption,
          'answer': answer,
        }),
      ).timeout(const Duration(seconds: 10));

      developer.log('[AnalyticsService] saveCoachResponse status=${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      developer.log('Error saving coach response: $e');
      return false;
    }
  }

  static Future<List<dynamic>?> getChatbotResponses() async {
      try {
        final token = await AuthService.getAccessToken();
        if (token == null) return null;

        final response = await http.get(
          Uri.parse('$_baseUrl/coach-responses'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return data['responses'] as List<dynamic>?;
        }
        return null;
      } catch (e) {
        developer.log('Error fetching chatbot responses: $e');
        return null;
      }
    }
  }

