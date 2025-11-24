import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'env_service.dart';

class DiseaseService {
  static String get _baseUrl => EnvService.apiBaseUrl;

  static Future<Map<String, dynamic>?> getExercisesForDisease(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/disease/$key/exercises');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    developer.log('Failed to fetch disease exercises: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getDietForDisease(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/disease/$key/diet');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    developer.log('Failed to fetch disease diet: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getDetailedDiseaseInfo(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/disease/$key/detailed');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    developer.log('Failed to fetch detailed disease info: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<Map<String, dynamic>?> getFullDiseaseProfile(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/disease/$key/full-profile');

    final res = await http.get(url, headers: {
      if (token != null) 'Authorization': 'Bearer $token'
    });

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    developer.log('Failed to fetch full disease profile: ${res.statusCode} ${res.body}');
    return null;
  }

  static Future<List<dynamic>?> getAllDiseases() async {
    final url = Uri.parse('$_baseUrl/api/disease');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return null;
  }

  static Future<List<dynamic>?> searchDiseases(String query) async {
    final url = Uri.parse('$_baseUrl/api/disease?search=$query');
    final res = await http.get(url);
    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    return null;
  }

  static Future<Map<String, dynamic>?> getConditionInsights(
    String query, {
    List<Map<String, dynamic>> history = const [],
    String? language,
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return null;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    final url = Uri.parse('$_baseUrl/api/disease/insights');

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final body = <String, dynamic>{
      'query': trimmedQuery,
      if (history.isNotEmpty) 'history': history,
      if (language != null && language.trim().isNotEmpty) 'language': language,
    };

    final res = await http.post(url, headers: headers, body: jsonEncode(body));

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    developer.log(
      'Failed to fetch condition insights: ${res.statusCode} ${res.body}',
    );
    throw Exception('Unable to fetch condition insights');
  }
}

