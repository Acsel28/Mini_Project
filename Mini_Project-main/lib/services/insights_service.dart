import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'env_service.dart';

class InsightsService {
  static String get _baseUrl => '${EnvService.apiBaseUrl}/api/analytics';

  static Future<Map<String, dynamic>?> getTrends() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/trends'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPrediction() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/predict'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Fetch dynamic health insights based on logged hydration and sleep data
  static Future<Map<String, dynamic>?> getDynamicInsights() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$_baseUrl/dynamic-insights'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      developer.log('Error fetching dynamic insights: $e');
      return null;
    }
  }
}
