import 'dart:convert';
import 'dart:developer' as developer;

import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;

import 'env_service.dart';

class TTSService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await _player.setReleaseMode(ReleaseMode.stop);
    _isInitialized = true;
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await init();

    final apiKey = EnvService.groqApiKey;
    if (apiKey == null || apiKey.isEmpty) {
      developer.log('Groq API key missing for TTS');
      return;
    }

    final uri = Uri.parse('https://api.groq.com/openai/v1/audio/speech');
    final chunks = _chunkText(text);
    if (chunks.isEmpty) return;

    try {
      for (final chunk in chunks) {
        final response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': EnvService.groqTtsModel,
            'voice': EnvService.groqTtsVoice,
            'response_format': 'wav',
            'input': chunk,
          }),
        );

        if (response.statusCode != 200) {
          developer.log('Groq TTS error: ${response.statusCode} ${response.body}');
          continue;
        }

        final audioBytes = response.bodyBytes;
        await _player.stop();
        await _player.play(BytesSource(audioBytes));
      }
    } catch (e) {
      developer.log('Groq TTS exception: $e');
    }
  }

  static List<String> _chunkText(String text, {int maxLength = 220}) {
    if (text.length <= maxLength) return [text];
    final parts = <String>[];
    var remaining = text.trim();
    while (remaining.length > maxLength) {
      final cutoff = remaining.lastIndexOf('. ', maxLength);
      final splitIndex = cutoff > 80 ? cutoff + 1 : maxLength;
      parts.add(remaining.substring(0, splitIndex).trim());
      remaining = remaining.substring(splitIndex).trim();
    }
    if (remaining.isNotEmpty) parts.add(remaining);
    return parts;
  }
  static Future<void> stop() async {
    if (!_isInitialized) return;
    await _player.stop();
  }

  static Future<void> speakMealInfo(String mealName, int calories, double protein) async {
    final text = 'Meal: $mealName. Calories: $calories. Protein: ${protein.toStringAsFixed(0)} grams.';
    await speak(text);
  }

  static Future<void> announceNavigation(String screenName) async {
    await speak('Navigated to $screenName');
  }

  static void dispose() {
    if (_isInitialized) {
      _player.dispose();
      _isInitialized = false;
    }
  }
}
