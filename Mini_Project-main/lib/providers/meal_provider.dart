import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../models/recipe_suggestions_model.dart';
import '../models/user_model.dart';
import '../services/meal_logging_service.dart';
import '../services/meal_service.dart';
import 'user_provider.dart';

// Meal plan state notifier
class MealPlanNotifier extends StateNotifier<MealPlan?> {
  final User? user;

  MealPlanNotifier(this.user) : super(null);

  Future<void> loadTodaysMealPlan({bool preferLogged = true}) async {
    final currentUser = user;
    if (currentUser == null) return;

    try {
      if (preferLogged) {
        final logged = await MealLoggingService.loadLoggedPlan(currentUser.id, DateTime.now());
        if (logged != null) {
          state = logged;
          return;
        }
      }

      final mealPlan = await MealService.getDailyMealPlan(currentUser);
      state = mealPlan;
    } catch (e) {
      developer.log('Error loading meal plan: $e');
      state = null;
    }
  }

  Future<void> regenerateMealPlan() async {
    final currentUser = user;
    if (currentUser == null) return;

    await MealLoggingService.clearLoggedPlan(currentUser.id, DateTime.now());
    state = null; // Show loading
    await loadTodaysMealPlan(preferLogged: false);
  }

  Future<bool> logMeal(Meal meal, {String? slot}) async {
    final currentUser = user;
    if (currentUser == null) return false;

    final today = DateTime.now();
    final normalizedDate = DateTime(today.year, today.month, today.day);
    final currentPlan = state;
    final MealPlan? existingPlan =
        currentPlan != null && _isSameDay(currentPlan.date, normalizedDate) ? currentPlan : null;

    final MealPlan basePlan = existingPlan ??
        MealPlan.fromMeals(
          id: '${currentUser.id}_${normalizedDate.toIso8601String()}',
          date: normalizedDate,
        );

    final updated = _applyMealToPlan(basePlan, meal, slot);
    state = updated;
    await MealLoggingService.saveLoggedPlan(currentUser.id, updated);
    return true;
  }

  MealPlan _applyMealToPlan(MealPlan base, Meal meal, String? slot) {
    final normalizedSlot = _normalizeSlot(slot ?? meal.category);
    var breakfast = base.breakfast;
    var lunch = base.lunch;
    var dinner = base.dinner;
    final snacks = List<Meal>.from(base.snacks);

    switch (normalizedSlot) {
      case 'breakfast':
        breakfast = meal;
        break;
      case 'lunch':
        lunch = meal;
        break;
      case 'dinner':
        dinner = meal;
        break;
      default:
        snacks.add(meal);
    }

    return MealPlan.fromMeals(
      id: base.id,
      date: DateTime(base.date.year, base.date.month, base.date.day),
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks,
    );
  }

  String _normalizeSlot(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('breakfast')) return 'breakfast';
    if (value.contains('lunch')) return 'lunch';
    if (value.contains('dinner')) return 'dinner';
    if (value.contains('snack')) return 'snack';
    return 'snack';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Recipe suggestions notifier
class RecipeSuggestionsNotifier extends StateNotifier<AsyncValue<RecipeSuggestionsResult>> {
  RecipeSuggestionsNotifier() : super(AsyncValue.data(RecipeSuggestionsResult.empty()));

  Future<void> getRecipesByIngredients(List<String> ingredients) async {
    final cleaned = ingredients.map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    if (cleaned.isEmpty) {
      state = AsyncValue.data(RecipeSuggestionsResult.empty());
      return;
    }

    state = const AsyncValue.loading();

    try {
      final result = await MealService.getRecipesByIngredients(cleaned);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Providers
final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan?>((ref) {
  final user = ref.watch(userProvider);
  return MealPlanNotifier(user);
});

final recipeSuggestionsProvider =
    StateNotifierProvider<RecipeSuggestionsNotifier, AsyncValue<RecipeSuggestionsResult>>((ref) {
  return RecipeSuggestionsNotifier();
});

// Daily progress provider
final dailyProgressProvider = Provider<Map<String, double>>((ref) {
  final mealPlan = ref.watch(mealPlanProvider);
  final user = ref.watch(userProvider);

  if (mealPlan == null || user == null) {
    return {
      'caloriesConsumed': 0.0,
      'targetCalories': 2000.0,
      'proteinConsumed': 0.0,
      'carbsConsumed': 0.0,
      'fatConsumed': 0.0,
    };
  }

  return {
    'caloriesConsumed': mealPlan.totalCalories.toDouble(),
    'targetCalories': user.targetCalories.toDouble(),
    'proteinConsumed': mealPlan.totalProtein,
    'carbsConsumed': mealPlan.totalCarbs,
    'fatConsumed': mealPlan.totalFat,
  };
});
