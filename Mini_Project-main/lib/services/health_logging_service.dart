import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HealthLoggingService {
  static const String baseUrl = "http://localhost:4000";

  // Log water/hydration
  static Future<bool> logWater(int amountMl) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('No auth token available for water logging');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/analytics/health/hydration');
      print('Attempting to log water: amount=$amountMl');
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"amount": amountMl}),
      );

      print('logWater status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Water logging failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error logging water: $e');
      return false;
    }
  }

  // Log sleep
  static Future<bool> logSleep(double hours, {String quality = 'good'}) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        print('No auth token available for sleep logging');
        return false;
      }

      final url = Uri.parse('$baseUrl/api/analytics/health/sleep');
      print('Attempting to log sleep: hours=$hours, quality=$quality');
      
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token"
        },
        body: jsonEncode({"hours": hours, "quality": quality}),
      );

      print('logSleep status=${response.statusCode} body=${response.body}');
      if (response.statusCode == 200) {
        return true;
      } else {
        print('Sleep logging failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error logging sleep: $e');
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

      print('getHydrationSummary status=${response.statusCode}');
      if (response.statusCode != 200) return null;

      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting hydration summary: $e');
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

      print('getSleepSummary status=${response.statusCode}');
      if (response.statusCode != 200) return null;

      return jsonDecode(response.body);
    } catch (e) {
      print('Error getting sleep summary: $e');
      return null;
    }
  }
}
