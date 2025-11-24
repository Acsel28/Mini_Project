import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'auth_service.dart';
import 'env_service.dart';

class CoachService {
  static String get _baseUrl => '${EnvService.apiBaseUrl}/api/coach/ask';

  static Future<String?> askCoach({
    required String question,
    List<Map<String, String>> history = const [],
    String? language,
  }) async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null) {
        developer.log('CoachService: missing auth token');
        return null;
      }

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'question': question,
              'history': history,
              if (language != null) 'language': language,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['answer']?.toString();
      }

      developer.log('CoachService error ${response.statusCode}: ${response.body}');
      return null;
    } catch (e) {
      developer.log('CoachService exception: $e');
      return null;
    }
  }
}
