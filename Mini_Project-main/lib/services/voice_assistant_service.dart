import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

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

  static Future<bool> ensureMicPermission({bool request = true}) async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    if (!request && status.isPermanentlyDenied) return false;

    if (status.isDenied || status.isRestricted || status.isLimited || status.isPermanentlyDenied) {
      status = await Permission.microphone.request();
    }

    return status.isGranted;
  }

  static Future<bool> _guardMicrophone({Function(String)? onTranscript}) async {
    final granted = await ensureMicPermission();
    if (granted) return true;

    onTranscript?.call('Microphone permission required');
    await TTSService.speak('I need access to your microphone to keep listening. Please enable it in settings.');
    return false;
  }

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
    if (!await _guardMicrophone(onTranscript: onTranscript)) return;
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
    if (!await _guardMicrophone()) return null;
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
        await TTSService.speak('Which condition should I focus on? For example: knee pain or lower back pain.');
        return;
      }
      final query = key.replaceAll('_', ' ');
      final handled = await _handleConditionQuery(query, ref: ref);
      if (!handled) {
        await TTSService.speak('I could not fetch insights right now. Please try again in a moment.');
      }
      return;
    }

    if (lower.contains('analytics')) {
      final intent = VoiceCommandResult(intent: 'open_screen', entities: const {'screen': 'analytics'});
      final handled = await VoiceCommandRouter.execute(intent, ref: ref);
      if (!handled) {
        await TTSService.speak('I could not open analytics just yet.');
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
    await TTSService.speak('Sorry, I did not understand that command. Try: Generate my meal plan, Add meal log, What\'s today\'s breakfast, or Show exercises for knee pain');
  }

  // Allow UI to provide the current step list for navigation with voice
  static void setLastSteps(List<String> steps) {
    _lastSteps = steps;
    _lastStepIndex = 0;
  }

  static Future<bool> _handleConditionQuery(String query, {WidgetRef? ref}) async {
    final synthetic = VoiceCommandResult(
      intent: 'search_condition',
      entities: {'condition': query},
    );
    return VoiceCommandRouter.execute(synthetic, ref: ref);
  }
}
