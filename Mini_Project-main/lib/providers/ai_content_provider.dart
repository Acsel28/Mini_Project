import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_content_models.dart';
import '../services/ai_content_service.dart';
import 'meal_provider.dart';
import 'user_provider.dart';

final aiSmartSuggestionsProvider = FutureProvider<List<AiSmartSuggestion>>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  return AiContentService.fetchSmartSuggestions(user: user, mealPlan: plan, language: user?.language);
});

final aiTimelineProvider = FutureProvider<List<AiTimelineEntry>>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  return AiContentService.fetchMealTimeline(user: user, mealPlan: plan, language: user?.language);
});

final aiInsightsProvider = FutureProvider<List<AiInsight>>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  return AiContentService.fetchHealthInsights(user: user, mealPlan: plan, language: user?.language);
});

final aiMacroBreakdownProvider = FutureProvider<AiMacroBreakdown?>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  return AiContentService.fetchMacroBreakdown(user: user, mealPlan: plan, language: user?.language);
});

final aiCuratedMealNotesProvider = FutureProvider<List<AiCuratedMealNote>>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  if (plan == null) return [];
  return AiContentService.fetchCuratedMealNotes(user: user, mealPlan: plan, language: user?.language);
});

final mealStudioIdeasProvider = FutureProvider.family<List<MealStudioIdea>, String>((ref, mealType) async {
  final user = ref.watch(userProvider);
  return AiContentService.fetchMealStudioIdeas(mealType: mealType, user: user, language: user?.language);
});

final weeklyPlanProvider = FutureProvider<List<AiWeekPlanDay>>((ref) async {
  final user = ref.watch(userProvider);
  final plan = ref.watch(mealPlanProvider);
  return AiContentService.fetchWeeklyPlan(user: user, mealPlan: plan, language: user?.language);
});
