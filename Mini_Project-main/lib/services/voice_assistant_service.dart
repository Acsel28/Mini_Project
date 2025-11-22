import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'disease_service.dart';
import 'meal_service.dart';
import 'tts_service.dart';
import 'user_service.dart';
import 'ai_command_service.dart';
import '../models/voice_command_result.dart';
import 'voice_command_router.dart';

class VoiceAssistantService {
  static final stt.SpeechToText _stt = stt.SpeechToText();
  static bool _initialized = false;
  static bool _speechReady = false;
  static bool _listening = false;
  static int _lastStepIndex = 0;
  static List<String> _lastSteps = [];

  static Future<void> init() async {
    if (_initialized) return;
    try {
      await TTSService.init();
      _speechReady = await _stt.initialize(
        onStatus: _handleStatus,
        onError: (error) => developer.log('Speech error: $error'),
      );
      _initialized = true;
    } catch (e) {
      developer.log('VoiceAssistant init error: $e');
    }
  }

  static Future<void> startListening(
    Function(String) onTranscript, {
    WidgetRef? ref,
    Duration listenFor = const Duration(seconds: 12),
  }) async {
    await init();
    if (!_speechReady) {
      onTranscript('Voice input unavailable');
      return;
    }

    await _listenInternal(
      onPartial: onTranscript,
      onFinal: (spoken) async {
        await handleCommand(spoken, ref: ref);
      },
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 4),
    );
  }

  static Future<void> promptAndListen({
    required String prompt,
    required Function(String) onTranscript,
    WidgetRef? ref,
    Duration listenFor = const Duration(seconds: 12),
  }) async {
    await init();
    await TTSService.speak(prompt);
    await Future.delayed(const Duration(milliseconds: 250));
    await startListening(onTranscript, ref: ref, listenFor: listenFor);
  }

  static Future<void> stopListening() async {
    try {
      _stt.stop();
      _listening = false;
    } catch (_) {}
  }

  static Future<String?> captureSingleCommand({
    String? prompt,
    Duration listenFor = const Duration(seconds: 5),
  }) async {
    await init();
    if (!_speechReady) return null;
    if (prompt != null) await TTSService.speak(prompt);

    final completer = Completer<String?>();

    unawaited(_listenInternal(
      listenFor: listenFor,
      runAssistantActions: false,
      onPartial: (_) {},
      onFinal: (spoken) async {
        if (!completer.isCompleted) completer.complete(spoken);
      },
    ));

    return completer.future.timeout(
      listenFor + const Duration(seconds: 2),
      onTimeout: () => null,
    );
  }

  static Future<void> _listenInternal({
    required void Function(String) onPartial,
    required FutureOr<void> Function(String) onFinal,
    Duration listenFor = const Duration(seconds: 8),
    Duration pauseFor = const Duration(seconds: 3),
    bool runAssistantActions = true,
  }) async {
    if (_listening) await stopListening();

    _listening = true;
    final available = await _stt.initialize(
      onStatus: _handleStatus,
      onError: (error) => developer.log('Speech error: $error'),
    );
    if (!available) {
      _listening = false;
      onPartial('Speech service unavailable');
      return;
    }

    _stt.listen(
      listenFor: listenFor,
      pauseFor: pauseFor,
      partialResults: true,
      sampleRate: 44100,
      localeId: 'en_US',
      onResult: (result) async {
        final words = result.recognizedWords.trim();
        if (words.isEmpty) return;
        onPartial(words);

        if (result.finalResult) {
          _listening = false;
          await _stt.stop();
          if (runAssistantActions) {
            await onFinal(words);
          } else {
            await onFinal(words);
          }
        }
      },
    );
  }

  static void _handleStatus(String status) {
    _listening = status == 'listening';
  }

  static Future<void> handleCommand(String text, {WidgetRef? ref}) async {
    final lower = text.toLowerCase();
    final VoiceCommandResult? aiIntent = await AiCommandService.interpret(text);
    if (aiIntent != null) {
      final handled = await VoiceCommandRouter.execute(aiIntent, ref: ref);
      if (handled) return;
    }

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
          await TTSService.speak('Your meal plan has been generated. Breakfast is ${plan.breakfast?.name ?? 'not set yet'}');
        } else {
          await TTSService.speak('No meal plan is available yet. Log your meals to unlock recommendations.');
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
