import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static String _currentLanguage = 'en-US';

  // Initialize TTS service
  static Future<void> init() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setVolume(1.0);
      _isInitialized = true;
      print('TTS Service initialized');
    } catch (e) {
      print('TTS Initialization error: \$e');
    }
  }

  // Speak text
  static Future<void> speak(String text) async {
    if (!_isInitialized) await init();

    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS Speak error: \$e');
    }
  }

  // Stop speaking
  static Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      await _flutterTts.stop();
    } catch (e) {
      print('TTS Stop error: \$e');
    }
  }

  // Set language
  static Future<void> setLanguage(String language) async {
    if (!_isInitialized) await init();

    _currentLanguage = language;
    try {
      await _flutterTts.setLanguage(language);
    } catch (e) {
      print('TTS Set Language error: \$e');
    }
  }

  // Speak meal information
  static Future<void> speakMealInfo(String mealName, int calories, double protein) async {
    final text = "Meal: \$mealName. Calories: \$calories. Protein: \${protein.toStringAsFixed(0)} grams.";
    await speak(text);
  }

  // Quick announcements
  static Future<void> announceNavigation(String screenName) async {
    await speak("Navigated to \$screenName");
  }

  // Cleanup
  static void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
  }
}
