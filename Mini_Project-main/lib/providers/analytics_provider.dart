import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

// User stats provider - fetches user health metrics from backend
final userStatsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await AnalyticsService.getUserStats();
});

// Health recommendations provider - gets personalized health suggestions
final healthRecommendationsProvider = FutureProvider<List<dynamic>?>((ref) async {
  return await AnalyticsService.getRecommendations();
});

// Meal suggestions provider - gets meal recommendations for specific meal type
final mealSuggestionsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, mealType) async {
  return await AnalyticsService.getMealSuggestions(mealType: mealType);
});

// Health insights provider - gets health trends and insights
final healthInsightsProvider = FutureProvider<List<dynamic>?>((ref) async {
  return await AnalyticsService.getHealthInsights();
});

// Breakfast suggestions
final breakfastSuggestionsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await ref.watch(mealSuggestionsProvider('breakfast').future);
});

// Lunch suggestions
final lunchSuggestionsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await ref.watch(mealSuggestionsProvider('lunch').future);
});

// Dinner suggestions
final dinnerSuggestionsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return await ref.watch(mealSuggestionsProvider('dinner').future);
});

// Combined analytics data provider
final combinedAnalyticsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final stats = await ref.watch(userStatsProvider.future);
  final recommendations = await ref.watch(healthRecommendationsProvider.future);
  final insights = await ref.watch(healthInsightsProvider.future);

  if (stats == null) return null;

  return {
    'stats': stats,
    'recommendations': recommendations ?? [],
    'insights': insights ?? [],
  };
});

// Stateful provider for tracking selected date
final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

// Stateful provider for tracking daily calorie intake
final dailyCalorieProvider = StateProvider<double>((ref) {
  return 0.0;
});

// Stateful provider for tracking water intake
final dailyWaterProvider = StateProvider<double>((ref) {
  return 0.0;
});

// Stateful provider for tracking steps
final dailyStepsProvider = StateProvider<int>((ref) {
  return 0;
});

// Stateful provider for favorite meals
final favoriteMealsProvider = StateNotifierProvider<FavoriteMealsNotifier, List<String>>((ref) {
  return FavoriteMealsNotifier();
});

class FavoriteMealsNotifier extends StateNotifier<List<String>> {
  FavoriteMealsNotifier() : super([]);

  void addFavorite(String mealId) {
    if (!state.contains(mealId)) {
      state = [...state, mealId];
    }
  }

  void removeFavorite(String mealId) {
    state = state.where((id) => id != mealId).toList();
  }

  void clearFavorites() {
    state = [];
  }

  bool isFavorite(String mealId) {
    return state.contains(mealId);
  }
}
