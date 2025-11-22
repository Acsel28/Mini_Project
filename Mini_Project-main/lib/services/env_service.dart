import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static const String _defaultChatModel = 'moonshotai/kimi-k2-instruct-0905';
  static const String _defaultTtsModel = 'playai-tts';
  static const String _defaultTtsVoice = 'Aaliyah-PlayAI';

  static String? _read(String key) {
    final compiled = _compiledValue(key);
    if (compiled != null && compiled.isNotEmpty) return compiled;

    if (dotenv.isInitialized) {
      final value = dotenv.env[key];
      if (value != null && value.isNotEmpty) return value;
    }

    return null;
  }

  static String? _compiledValue(String key) {
    switch (key) {
      case 'GROQ_API_KEY':
        {
          const value = String.fromEnvironment('GROQ_API_KEY', defaultValue: '');
          return value.isEmpty ? null : value;
        }
      case 'GROQ_CHAT_MODEL':
        {
          const value = String.fromEnvironment('GROQ_CHAT_MODEL', defaultValue: '');
          return value.isEmpty ? null : value;
        }
      case 'GROQ_TTS_MODEL':
        {
          const value = String.fromEnvironment('GROQ_TTS_MODEL', defaultValue: '');
          return value.isEmpty ? null : value;
        }
      case 'GROQ_TTS_VOICE':
        {
          const value = String.fromEnvironment('GROQ_TTS_VOICE', defaultValue: '');
          return value.isEmpty ? null : value;
        }
      default:
        return null;
    }
  }

  static String? get groqApiKey => _read('GROQ_API_KEY');

  static String get groqChatModel => _read('GROQ_CHAT_MODEL') ?? _defaultChatModel;

  static String get groqTtsModel => _read('GROQ_TTS_MODEL') ?? _defaultTtsModel;

  static String get groqTtsVoice => _read('GROQ_TTS_VOICE') ?? _defaultTtsVoice;
}
