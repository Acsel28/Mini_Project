import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/voice_command_result.dart';
import '../providers/meal_provider.dart';
import '../providers/health_logging_provider.dart';
import 'app_navigation_service.dart';
import 'disease_service.dart';
import 'health_logging_service.dart';
import 'meal_service.dart';
import 'tts_service.dart';
import 'user_service.dart';

class VoiceCommandRouter {
  static Future<bool> execute(VoiceCommandResult command, {WidgetRef? ref}) async {
    developer.log('Voice intent: ${command.intent} entities=${command.entities}');
    switch (command.intent) {
      case 'open_screen':
        return _openScreen(command.entityAsString('screen'));
      case 'summarize_meal_plan':
        return _summarizeMeal(command.entityAsString('meal_type'));
      case 'generate_meal_plan':
        return _regeneratePlan(ref);
      case 'add_meal_log':
        return _openMealLog();
      case 'log_water':
        return _logWater(command.entityAsInt('water_ml'), ref);
      case 'log_sleep':
        return _logSleep(command.entityAsDouble('sleep_hours'), ref);
      case 'search_condition':
        return _searchCondition(command.entityAsString('condition'));
      case 'coach_tip':
        return _coachTip(command.entityAsString('topic'));
      case 'help':
      default:
        await TTSService.speak(
          'You can say: "Open insights", "Log 300 milliliters water", "What is today\'s breakfast", or "Regenerate my plan".',
        );
        return true;
    }
  }

  static Future<bool> _openScreen(String? rawScreen) async {
    if (rawScreen == null || rawScreen.isEmpty) {
      await TTSService.speak('Which screen should I open? Try home, insights, progress, profile, coach or search.');
      return false;
    }
    final normalized = _normalizeScreen(rawScreen);
    await AppNavigationService.openScreen(normalized);
    await TTSService.speak('Opening $normalized');
    return true;
  }

  static Future<bool> _summarizeMeal(String? mealType) async {
    try {
      final user = await UserService.fetchCurrentUser();
      if (user == null) {
        await TTSService.speak('I do not have your profile available.');
        return false;
      }
      final plan = await MealService.getDailyMealPlan(user);
      if (plan == null) {
        await TTSService.speak('No meal plan is available yet. Log a meal to get recommendations.');
        return false;
      }
      final type = (mealType ?? 'breakfast').toLowerCase();
      final meal = {
        'breakfast': plan.breakfast,
        'lunch': plan.lunch,
        'dinner': plan.dinner,
      }[type] ?? plan.breakfast;
      if (meal == null) {
        await TTSService.speak('I could not find that meal in your plan.');
        return false;
      }
      await TTSService.speak(
        '${meal.name} is ${meal.calories} calories with ${meal.protein.toStringAsFixed(0)} grams of protein.',
      );
      return true;
    } catch (e) {
      await TTSService.speak('I was unable to read your meal plan.');
      return false;
    }
  }

  static Future<bool> _regeneratePlan(WidgetRef? ref) async {
    try {
      final user = await UserService.fetchCurrentUser();
      if (user == null) {
        await TTSService.speak('Sign in to generate a plan.');
        return false;
      }
      if (ref != null) {
        await ref.read(mealPlanProvider.notifier).regenerateMealPlan();
      } else {
        await MealService.getDailyMealPlan(user);
      }
      await TTSService.speak('Regenerating your personalized meal plan now.');
      return true;
    } catch (e) {
      await TTSService.speak('Meal plan regeneration is unavailable.');
      return false;
    }
  }

  static Future<bool> _logWater(int? amount, WidgetRef? ref) async {
    final ml = amount ?? 250;
    final success = await HealthLoggingService.logWater(ml);
    if (success && ref != null) {
      await ref.read(healthLoggingProvider.notifier).loadDailySummary();
    }
    await TTSService.speak(success ? 'Logged $ml milliliters of water.' : 'I could not log your water intake.');
    return success;
  }

  static Future<bool> _logSleep(double? hours, WidgetRef? ref) async {
    final value = hours ?? 7.0;
    final success = await HealthLoggingService.logSleep(value);
    if (success && ref != null) {
      await ref.read(healthLoggingProvider.notifier).loadDailySummary();
    }
    await TTSService.speak(success ? 'Marked $value hours of sleep.' : 'I could not save your sleep log.');
    return success;
  }

  static Future<bool> _searchCondition(String? condition) async {
    final query = condition?.trim();
    if (query == null || query.isEmpty) {
      await TTSService.speak('Which condition do you want insights for?');
      return false;
    }

    try {
      final payload = await DiseaseService.getConditionInsights(query);
      if (payload == null) {
        await TTSService.speak('I could not find curated insights right now. Please try again.');
        return false;
      }

      await AppNavigationService.openScreen('search', args: {'query': query});

      final answer = payload['answer'] as Map<String, dynamic>?;
      final summary = (answer?['condition_summary'] as String? ?? '').trim();
      final diet = _firstString(answer?['diet_guidance']);
      final exercise = _firstString(answer?['exercise_plan']);

      final narration = [
        'Here is what I found for $query.',
        if (summary.isNotEmpty) summary,
        if (diet != null) 'Diet focus: $diet.',
        if (exercise != null) 'Movement cue: $exercise.',
      ].join(' ');

      await TTSService.speak(narration.trim());
      return true;
    } catch (e) {
      developer.log('Condition insight error: $e');
      await TTSService.speak('I could not generate insights for $query right now.');
      return false;
    }
  }

  static Future<bool> _coachTip(String? topic) async {
    await AppNavigationService.openScreen('coach');
    await TTSService.speak('Opening your AI coach${topic != null ? ' about $topic' : ''}.');
    return true;
  }

  static Future<bool> _openMealLog() async {
    await AppNavigationService.openMealLog();
    await TTSService.speak('Opening the meal log so you can capture it now.');
    return true;
  }

  static String _normalizeScreen(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('insight')) return 'insights';
    if (value.contains('progress') || value.contains('trend')) return 'progress';
    if (value.contains('profile') || value.contains('account')) return 'profile';
    if (value.contains('ingredient') || value.contains('pantry')) return 'ingredients';
    if (value.contains('search') || value.contains('condition')) return 'search';
    if (value.contains('coach') || value.contains('chat')) return 'coach';
    if (value.contains('analytics')) return 'analytics';
    return 'home';
  }

  static String? _firstString(dynamic source) {
    if (source is String && source.trim().isNotEmpty) {
      return source.trim();
    }
    if (source is Iterable) {
      for (final item in source) {
        final text = item?.toString().trim();
        if (text != null && text.isNotEmpty) {
          return text;
        }
      }
    }
    return null;
  }
}
