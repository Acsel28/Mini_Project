import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'env_service.dart';

class AuthResult {
  final bool success;
  final String? message;

  AuthResult(this.success, this.message);
}

class AuthService {
  static String get _baseUrl => EnvService.apiBaseUrl;

  // ----------------------------
  // LOGIN
  // ----------------------------
  static Future<AuthResult> login(String email, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/api/auth/login');

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      developer.log('AuthService.login status=${response.statusCode} body=${response.body}');
      final data = _safeDecode(response.body);

      if (response.statusCode != 200) {
        return AuthResult(false, data?["error"]?.toString() ?? "Login failed");
      }

      if (data == null) {
        return AuthResult(false, 'Login failed: unexpected response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("accessToken", data["accessToken"]);
      await prefs.setString("refreshToken", data["refreshToken"]);
      await prefs.setString("userId", data["user"]["id"]);

      return AuthResult(true, null);

    } catch (e) {
      return AuthResult(false, e.toString());
    }
  }

  // ----------------------------
  // REGISTER
  // ----------------------------
  static Future<AuthResult> register(
    String email,
    String password,
    String name, {
    double? height,
    double? weight,
    int? age,
    String? gender,
    String? disease,
    String? dietPreference,
    String? fitnessGoal,
    String? activityLevel,
    String? allergies,
    String? mealType,
    int? targetCalories,
  }) async {
    try {
      final url = Uri.parse("$_baseUrl/api/auth/register");

      final body = <String, dynamic>{
        "email": email,
        "password": password,
        "name": name,
      };

      if (height != null) body["height_cm"] = height;
      if (weight != null) body["weight_kg"] = weight;
      if (age != null) body["age"] = age;
      if (gender != null) body["gender"] = gender;
      if (disease != null) body["disease"] = disease;
      if (dietPreference != null) body["diet_preference"] = dietPreference;
      if (fitnessGoal != null) body["fitness_goal"] = fitnessGoal;
      if (activityLevel != null) body["activity_level"] = activityLevel;
      if (allergies != null) body["allergies"] = allergies;
      if (mealType != null) body["meal_type"] = mealType;
      if (targetCalories != null) body["target_calories"] = targetCalories;

      final res = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      developer.log('REGISTER status=${res.statusCode} body=${res.body}');

      if (res.statusCode != 200) {
        final err = _safeDecode(res.body);
        return AuthResult(false, err?["error"]?.toString() ?? "Registration failed");
      }

      final data = _safeDecode(res.body);
      if (data == null) {
        return AuthResult(false, "Registration failed: unexpected response");
      }

      final prefs = await SharedPreferences.getInstance();
      prefs.setString("accessToken", data["accessToken"]);
      prefs.setString("refreshToken", data["refreshToken"]);
      prefs.setString("userId", data["user"]["id"]);

      return AuthResult(true, "Registered successfully");
    } catch (e) {
      return AuthResult(false, e.toString());
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("accessToken");
  }
}

Map<String, dynamic>? _safeDecode(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  } catch (e) {
    developer.log('AuthService decode error: $e');
    return null;
  }
}
