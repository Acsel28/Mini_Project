// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // For web/desktop: localhost
  static String baseUrl = 'http://localhost:4000';
  static const _profilePath = '/api/users/profile';
  static const _mePath = '/api/users/me';

  // PUT /api/users/profile
  static Future<http.Response> updateProfile(Map<String, dynamic> profileData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('No access token found - ensure registration/login succeeded.');

    final url = Uri.parse('$baseUrl$_profilePath');
    final res = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(profileData),
    );

    // debug
    // ignore: avoid_print
    print('ProfileService.updateProfile -> ${res.statusCode} ${res.body}');

    if (res.statusCode == 401) {
      throw Exception('Unauthorized (token missing or expired).');
    }
    if (res.statusCode != 200) {
      throw Exception('Profile update failed: ${res.body}');
    }
    return res;
  }

  // GET /api/users/me -> { user: {...}, profile: {...} }
  static Future<Map<String, dynamic>> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) throw Exception('No access token');

    final url = Uri.parse('$baseUrl$_mePath');
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load profile: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid profile response format');
    }
    return decoded;
  }
}
