import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import '../services/meal_service.dart';
import 'user_provider.dart';

// Meal plan state notifier
class MealPlanNotifier extends StateNotifier<MealPlan?> {
  final User? user;

  MealPlanNotifier(this.user) : super(null);

  Future<void> loadTodaysMealPlan() async {
    if (user == null) return;

    try {
      final mealPlan = await MealService.getDailyMealPlan(user!);
      state = mealPlan;
    } catch (e) {
      print('Error loading meal plan: \$e');
      state = null;
    }
  }

  Future<void> regenerateMealPlan() async {
    if (user == null) return;

    state = null; // Show loading
    await loadTodaysMealPlan();
  }
}

// Recipe suggestions notifier
class RecipeSuggestionsNotifier extends StateNotifier<AsyncValue<List<Meal>>> {
  RecipeSuggestionsNotifier() : super(const AsyncValue.data([]));

  Future<void> getRecipesByIngredients(List<String> ingredients) async {
    state = const AsyncValue.loading();

    try {
      final recipes = await MealService.getRecipesByIngredients(ingredients);
      state = AsyncValue.data(recipes);
    } catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }
}

// Providers
final mealPlanProvider = StateNotifierProvider<MealPlanNotifier, MealPlan?>((ref) {
  final user = ref.watch(userProvider);
  return MealPlanNotifier(user);
});

final recipeSuggestionsProvider = StateNotifierProvider<RecipeSuggestionsNotifier, AsyncValue<List<Meal>>>((ref) {
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
