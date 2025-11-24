import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvService {
  static const String _defaultChatModel = 'moonshotai/kimi-k2-instruct-0905';
  static const String _defaultTtsModel = 'playai-tts';
  static const String _defaultTtsVoice = 'Aaliyah-PlayAI';
  static final String _defaultApiBaseUrl = _detectDefaultApiBaseUrl();

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
      case 'API_BASE_URL':
        {
          const value = String.fromEnvironment('API_BASE_URL', defaultValue: '');
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

  static String get apiBaseUrl {
    final override = _read('API_BASE_URL');
    final resolved = (override == null || override.trim().isEmpty) ? _defaultApiBaseUrl : override.trim();
    return _normalizeBaseUrl(resolved);
  }

  static String _detectDefaultApiBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:4000';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:4000';
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return 'http://localhost:4000';
    }
  }

  static String _normalizeBaseUrl(String value) {
    var base = value;
    if (!base.startsWith('http://') && !base.startsWith('https://')) {
      base = 'http://$base';
    }
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      base = base.replaceFirst(RegExp(r'localhost|127\.0\.0\.1'), '10.0.2.2');
    }
    return base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  }
}
