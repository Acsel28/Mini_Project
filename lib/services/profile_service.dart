// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // For web/desktop, use localhost
  static String baseUrl = 'http://localhost:4000';
  static const _profilePath = '/api/users/profile';

  // Call PUT /api/users/profile with Authorization header
  static Future<http.Response> updateProfile(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('No access token found - ensure registration succeeded.');
    }

    final url = Uri.parse('$baseUrl$_profilePath');
    try {
      final res = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      // debug logs to console (visible in flutter console)
      // ignore: avoid_print
      print('ProfileService.updateProfile -> status ${res.statusCode}, body: ${res.body}');

      if (res.statusCode == 401) {
        throw Exception('Unauthorized (token missing or expired).');
      }
      if (res.statusCode != 200) {
        throw Exception('Profile update failed: ${res.body}');
      }
      return res;
    } catch (e) {
      // rethrow with extra context
      throw Exception('ProfileService.updateProfile error: $e');
    }
  }
}
