import 'meal_model.dart';

class RecipeSuggestionsResult {
  const RecipeSuggestionsResult({
    required this.recipes,
    required this.pantryMatches,
    required this.ingredients,
    required this.source,
    required this.fetchedAt,
  });

  final List<Meal> recipes;
  final List<Meal> pantryMatches;
  final List<String> ingredients;
  final String source;
  final DateTime fetchedAt;

  bool get isAiChef => source == 'llm' || source == 'ai_mix' || source == 'groq_ai';
  bool get isFallback => source.contains('fallback') || source == 'local_fallback';
  bool get isEmpty => recipes.isEmpty && pantryMatches.isEmpty;
  List<String> get topIngredients => ingredients.take(6).toList();

  RecipeSuggestionsResult copyWith({
    List<Meal>? recipes,
    List<Meal>? pantryMatches,
    List<String>? ingredients,
    String? source,
    DateTime? fetchedAt,
  }) {
    return RecipeSuggestionsResult(
      recipes: recipes ?? this.recipes,
      pantryMatches: pantryMatches ?? this.pantryMatches,
      ingredients: ingredients ?? this.ingredients,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  factory RecipeSuggestionsResult.empty() {
    return RecipeSuggestionsResult(
      recipes: const [],
      pantryMatches: const [],
      ingredients: const [],
      source: 'idle',
      fetchedAt: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
