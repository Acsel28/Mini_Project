import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'tts_service.dart';
import 'disease_service.dart';
import 'meal_service.dart';
import 'user_service.dart';

class VoiceAssistantService {
  static final stt.SpeechToText _stt = stt.SpeechToText();
  static bool _initialized = false;
  static String _lastTranscript = '';
  static int _lastStepIndex = 0;
  static List<String> _lastSteps = [];

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await TTSService.init();
      _initialized = true;
    } catch (e) {
      print('VoiceAssistant init error: $e');
    }
  }

  static Future<void> startListening(Function(String) onTranscript) async {
    if (!await _stt.initialize()) return;
    _stt.listen(onResult: (result) async {
      _lastTranscript = result.recognizedWords;
      onTranscript(_lastTranscript);
      await handleCommand(_lastTranscript);
    });
  }

  static Future<void> stopListening() async {
    try {
      _stt.stop();
    } catch (_) {}
  }

  static Future<void> handleCommand(String text) async {
    final lower = text.toLowerCase();

    // helper to map free text to disease key
    String? detectDiseaseKey(String sentence) {
      if (sentence.contains('knee')) return 'knee_pain';
      if (sentence.contains('back') || sentence.contains('lower back')) return 'lower_back_pain';
      if (sentence.contains('diabetes')) return 'diabetes_type2';
      if (sentence.contains('hypertension') || sentence.contains('blood pressure')) return 'hypertension';
      if (sentence.contains('pcos')) return 'pcos';
      if (sentence.contains('thyroid')) return 'thyroid';
      if (sentence.contains('obesity') || sentence.contains('overweight')) return 'obesity';
      return null;
    }

    if (lower.contains('generate') && lower.contains('meal')) {
      await TTSService.speak('Generating your meal plan');
      // call in-app meal generation / provider
      try {
        final user = await UserService.fetchCurrentUser();
        final plan = user != null ? await MealService.getDailyMealPlan(user) : null;
        if (plan != null) {
          await TTSService.speak('Your meal plan has been generated. Breakfast is ${plan.breakfast?.name ?? 'N/A'}');
        } else {
          await TTSService.speak('No meal plan available.');
        }
      } catch (e) {
        await TTSService.speak('I could not generate a meal plan right now.');
      }
      return;
    }

    if (lower.contains("today's breakfast") || (lower.contains('today') && lower.contains('breakfast'))) {
      try {
        final user = await UserService.fetchCurrentUser();
        final plan = user != null ? await MealService.getDailyMealPlan(user) : null;
        final b = plan?.breakfast;
        if (b != null) {
          await TTSService.speak('Today\'s breakfast is ${b.name}. It has ${b.calories} calories.');
        } else {
          await TTSService.speak('No breakfast planned.');
        }
      } catch (e) {
        await TTSService.speak('Failed to fetch breakfast.');
      }
      return;
    }

    if (lower.contains('show exercises') || lower.contains('exercises for') || lower.contains('exercise for')) {
      final key = detectDiseaseKey(lower);
      if (key == null) {
        await TTSService.speak('Which condition should I show exercises for? For example: knee pain or lower back pain.');
        return;
      }
      await TTSService.speak('Showing exercises for $key');
      final result = await DiseaseService.getExercisesForDisease(key);
      if (result != null) {
        final recs = result['recommendedExercises'] as List<dynamic>? ?? [];
        if (recs.isEmpty) {
          await TTSService.speak('No recommended exercises listed.');
        } else {
          final recNames = recs.map((e) => e['name']).take(5).join(', ');
          await TTSService.speak('Recommended: $recNames');
        }
      } else {
        await TTSService.speak('No exercises found for that condition.');
      }
      return;
    }

    if (lower.contains('next step')) {
      if (_lastSteps.isEmpty) {
        await TTSService.speak('There is no active set of steps.');
        return;
      }
      _lastStepIndex = (_lastStepIndex + 1) % _lastSteps.length;
      await TTSService.speak(_lastSteps[_lastStepIndex]);
      return;
    }

    if (lower.contains('repeat last step') || lower.contains('repeat step')) {
      if (_lastSteps.isEmpty) {
        await TTSService.speak('There is nothing to repeat.');
        return;
      }
      await TTSService.speak(_lastSteps[_lastStepIndex]);
      return;
    }

    // Fallback
    await TTSService.speak('Sorry, I did not understand that command. Try: Generate my meal plan, What\'s today\'s breakfast, or Show exercises for knee pain');
  }

  // Allow UI to provide the current step list for navigation with voice
  static void setLastSteps(List<String> steps) {
    _lastSteps = steps;
    _lastStepIndex = 0;
  }
}
