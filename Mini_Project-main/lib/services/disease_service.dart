import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DiseaseService {
  static const String baseUrl = "http://localhost:4000";

  static Future<Map<String, dynamic>?> getExercisesForDisease(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/api/disease/$key/exercises');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    print('Failed to fetch disease exercises: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getDietForDisease(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/api/disease/$key/diet');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    print('Failed to fetch disease diet: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getDetailedDiseaseInfo(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/api/disease/$key/detailed');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    print('Failed to fetch detailed disease info: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getFullDiseaseProfile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$baseUrl/api/disease/$key/full-profile');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    print('Failed to fetch full disease profile: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<List<dynamic>?> getAllDiseases() async {
    final url = Uri.parse('$baseUrl/api/disease');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return null;
  }

  static Future<List<dynamic>?> searchDiseases(String query) async {
    final url = Uri.parse('$baseUrl/api/disease?search=$query');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return null;
  }
}

