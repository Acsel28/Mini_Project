import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class HealthService {
  static const String _baseUrl = 'http://localhost:4000/api/health';

  static Future<bool> logHydration(int amount) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/hydration'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'amount': amount}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> logSleep(double hours, {String quality = 'good'}) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/sleep'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'hours': hours, 'quality': quality}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> getHydrationSummary() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/hydration-summary'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getSleepSummary() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/sleep-summary'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<List<dynamic>?> getChecklist() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;
      
      final response = await http.get(
        Uri.parse('$_baseUrl/checklist'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['checklist'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateChecklist(String label, bool done) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return false;
      
      final response = await http.post(
        Uri.parse('$_baseUrl/checklist'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'label': label, 'done': done}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
