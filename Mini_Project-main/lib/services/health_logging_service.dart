import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HealthLoggingService {
  static const String baseUrl = "http://localhost:4000";

  // Log water/hydration
  static Future<bool> logWater(int amountMl) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        developer.log('No auth token available for water logging');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/analytics/health/hydration');
      developer.log('Attempting to log water: amount=$amountMl');
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"amount": amountMl}),
      );

      developer.log('logWater status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log('Water logging failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('Error logging water: $e');
      return false;
    }
  }

  // Log sleep
  static Future<bool> logSleep(double hours, {String quality = 'good'}) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        developer.log('No auth token available for sleep logging');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/analytics/health/sleep');
      developer.log('Attempting to log sleep: hours=$hours, quality=$quality');
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"hours": hours, "quality": quality}),
      );

      developer.log('logSleep status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        developer.log('Sleep logging failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      developer.log('Error logging sleep: $e');
      return false;
    }
  }

  // Get today's hydration summary
  static Future<Map<String, dynamic>?> getHydrationSummary() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final url = Uri.parse('$baseUrl/api/analytics/health/hydration-summary');
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      developer.log('getHydrationSummary status=${response.statusCode}');
      if (response.statusCode != 200) return null;

      return jsonDecode(response.body);
    } catch (e) {
      developer.log('Error getting hydration summary: $e');
      return null;
    }
  }

  // Get today's sleep summary
  static Future<Map<String, dynamic>?> getSleepSummary() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final url = Uri.parse('$baseUrl/api/analytics/health/sleep-summary');
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token"
        },
      );

      developer.log('getSleepSummary status=${response.statusCode}');
      if (response.statusCode != 200) return null;

      return jsonDecode(response.body);
    } catch (e) {
      developer.log('Error getting sleep summary: $e');
      return null;
    }
  }
}
