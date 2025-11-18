import 'dart:convert';
import 'package:http/http.dart' as http;

class CoachService {
  static const String _baseUrl = 'http://localhost:4000/api/coach/ask';

  static Future<String?> askCoach(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'question': question}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
