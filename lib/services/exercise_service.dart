import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise_model.dart';

class ExerciseService {
  static const String baseUrl = 'http://localhost:4000';

  static Future<List<Exercise>> getExercises({String? condition}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    if (token == null) {
      throw Exception('No access token found – please log in again.');
    }

    final uri = Uri.parse('$baseUrl/api/exercises').replace(
      queryParameters: condition != null && condition.isNotEmpty
          ? {'condition': condition}
          : null,
    );

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Failed to load exercises: ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid exercises response format');
    }

    final list = decoded['exercises'];
    if (list is! List) return [];

    return list
        .whereType<Map>()
        .map((e) => Exercise.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }
}
