import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'env_service.dart';

class GroqService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  static Future<String?> _chatRequest({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int? maxTokens,
  }) async {
    final apiKey = EnvService.groqApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      developer.log('Groq API key missing');
      return null;
    }

    final uri = Uri.parse('$_baseUrl/chat/completions');
    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': EnvService.groqChatModel,
          'messages': messages,
          'temperature': temperature,
          'stream': false,
          'top_p': 1,
          if (maxTokens != null) 'max_completion_tokens': maxTokens,
        }),
      );

      if (response.statusCode != 200) {
        developer.log('Groq chat error: ${response.statusCode} ${response.body}');
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final choices = decoded['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) return null;
      final message = choices.first['message'] as Map<String, dynamic>?;
      final content = message?['content'];
      if (content is String) return content;
      if (content is List) {
        // Some models return tool messages as a list
        final buffer = StringBuffer();
        for (final part in content) {
          buffer.write(part.toString());
        }
        return buffer.isEmpty ? null : buffer.toString();
      }
      return content?.toString();
    } catch (e) {
      developer.log('Groq chat exception: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> structuredJson({
    required String prompt,
    double temperature = 0.7,
  }) async {
    final response = await _chatRequest(
      messages: [
        {
          'role': 'system',
          'content':
              'You are a structured-data nutrition copilot. Always respond with valid JSON only. Never wrap the response in Markdown fences or add commentary.',
        },
        {'role': 'user', 'content': prompt},
      ],
      temperature: temperature,
    );

    if (response == null) return null;
    final normalized = response
        .trim()
        .replaceAll(RegExp(r'^```json'), '')
        .replaceAll(RegExp(r'^```JSON'), '')
        .replaceAll(RegExp(r'```$'), '')
        .trim();
    try {
      return jsonDecode(normalized) as Map<String, dynamic>;
    } catch (e) {
      developer.log('Groq JSON parse error: $e | $normalized');
      return null;
    }
  }

  static Future<String?> conversationalResponse({
    required List<Map<String, String>> messages,
    double temperature = 0.7,
    int? maxTokens,
  }) {
    return _chatRequest(
      messages: messages,
      temperature: temperature,
      maxTokens: maxTokens,
    );
  }
}
