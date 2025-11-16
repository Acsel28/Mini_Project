// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  static const String baseUrl = "http://localhost:4000";

  static Future<User?> fetchCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");

    if (token == null) {
      print("❌ No access token stored.");
      return null;
    }

    final url = Uri.parse('$baseUrl/api/users/me');

    final response = await http.get(
      url,
      headers: {"Authorization": "Bearer $token"},
    );

    print("FETCH /me STATUS: ${response.statusCode}");
    print("FETCH /me BODY:\n${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final data = decoded is Map && decoded.containsKey('user') ? decoded['user'] : decoded;
      return User.fromMap(data as Map<String, dynamic>);
    }

    print("❌ Failed to load user: ${response.body}");
    return null;
  }

  static Future<bool> updateProfile({
    required String name,
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String language,
    required int targetCalories,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken");
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/api/users/profile');

    final body = jsonEncode({
      "name": name,
      "age": age,
      "gender": gender,
      "height_cm": heightCm,
      "weight_kg": weightKg,
      "language": language,
      "target_calories": targetCalories
    });

    final res = await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: body,
    );

    print("UPDATE /profile STATUS: ${res.statusCode} BODY: ${res.body}");

    return res.statusCode == 200;
  }
}
