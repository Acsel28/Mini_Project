import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import 'mealplan_service.dart';
import '../models/meal_model.dart';
import '../models/recipe_suggestions_model.dart';
import '../models/user_model.dart';
import 'auth_service.dart';
import 'env_service.dart';

class MealService {
  static String get _baseUrl => EnvService.apiBaseUrl;
  // Sample meal data
  static final List<Meal> _sampleMeals = [
    Meal(
      id: '1',
      name: 'Oats with Milk and Honey',
      category: 'breakfast',
      calories: 320,
      protein: 12.0,
      carbs: 45.0,
      fat: 8.0,
      ingredients: ['oats', 'milk', 'honey', 'banana'],
      instructions: [
        'Boil 200ml milk in a pan',
        'Add 50g oats and cook for 5 minutes',
        'Add honey and banana',
        'Serve hot'
      ],
      cookTime: '10 minutes',
      difficulty: 'Easy',
      cuisine: 'Continental',
      isVegetarian: true,
      createdAt: DateTime.now(),
    ),

    Meal(
      id: '2',
      name: 'Dal Rice with Vegetables',
      category: 'lunch',
      calories: 450,
      protein: 15.0,
      carbs: 70.0,
      fat: 10.0,
      ingredients: ['toor dal', 'basmati rice', 'turmeric', 'vegetables'],
      instructions: [
        'Cook rice separately',
        'Boil dal with turmeric',
        'Add vegetables to dal',
        'Serve with rice'
      ],
      cookTime: '30 minutes',
      difficulty: 'Medium',
      cuisine: 'Indian',
      isVegetarian: true,
      isVegan: true,
      createdAt: DateTime.now(),
    ),

    Meal(
      id: '3',
      name: 'Grilled Paneer Salad',
      category: 'dinner',
      calories: 350,
      protein: 20.0,
      carbs: 15.0,
      fat: 25.0,
      ingredients: ['paneer', 'lettuce', 'tomatoes', 'cucumber'],
      instructions: [
        'Grill paneer cubes',
        'Chop vegetables',
        'Mix everything',
        'Add dressing'
      ],
      cookTime: '15 minutes',
      difficulty: 'Easy',
      cuisine: 'Continental',
      isVegetarian: true,
      createdAt: DateTime.now(),
    ),

    Meal(
      id: '4',
      name: 'Quinoa Bowl',
      category: 'lunch',
      calories: 400,
      protein: 18.0,
      carbs: 55.0,
      fat: 12.0,
      ingredients: ['quinoa', 'broccoli', 'chickpeas', 'tahini'],
      instructions: [
        'Cook quinoa',
        'Steam broccoli',
        'Roast chickpeas',
        'Combine with tahini'
      ],
      cookTime: '25 minutes',
      difficulty: 'Easy',
      cuisine: 'Mediterranean',
      isVegetarian: true,
      isVegan: true,
      createdAt: DateTime.now(),
    ),
  ];

  // Get daily meal plan
  static Future<MealPlan?> getDailyMealPlan(User user) async {
    // Try backend-generated meal plan first
    try {
      final remote = await MealPlanService.generateForUser();
      if (remote != null) {
        final slots = remote['slots'] as Map<String, dynamic>?;
        if (slots == null) return null;
        // Convert to local Meal objects
        Meal? toMeal(Map<String, dynamic>? m, String category) {
          if (m == null) return null;
          return Meal(
            id: m['id'] ?? '',
            name: m['title'] ?? '',
            category: category,
            calories: (m['calories'] ?? 0).toInt(),
            protein: (m['protein'] ?? 0.0).toDouble(),
            carbs: (m['carbs'] ?? 0.0).toDouble(),
            fat: (m['fat'] ?? 0.0).toDouble(),
            ingredients: List<String>.from(m['ingredients'] ?? []),
            instructions: List<String>.from(m['recipe']['instructions'] ?? []),
            cookTime: m['recipe'] != null ? (m['recipe']['cookTime'] ?? '') : '',
            difficulty: (m['difficulty'] ?? 'Easy'),
            cuisine: (m['cuisine'] ?? 'General'),
            isVegetarian: (m['tags'] ?? []).contains('vegetarian'),
            isVegan: (m['tags'] ?? []).contains('vegan'),
            createdAt: DateTime.now(),
          );
        }

        Meal? firstMeal(String slot) {
          final list = slots[slot] as List<dynamic>?;
          if (list == null || list.isEmpty) return null;
          return toMeal(list.first as Map<String, dynamic>?, slot);
        }

        final breakfast = firstMeal('breakfast');
        final lunch = firstMeal('lunch');
        final dinner = firstMeal('dinner');
        final snacks = (slots['snacks'] as List<dynamic>? ?? const [])
            .map((m) => toMeal(m as Map<String, dynamic>?, 'snack'))
            .whereType<Meal>()
            .toList();

        return MealPlan.fromMeals(
          id: remote['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          breakfast: breakfast,
          lunch: lunch,
          dinner: dinner,
          snacks: snacks,
        );
      }
    } catch (e) {
      developer.log('Remote meal plan generation failed: $e');
    }
    return null;
  }

  // Get recipes by ingredients
  static Future<RecipeSuggestionsResult> getRecipesByIngredients(List<String> ingredients) async {
    final cleaned = ingredients.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    if (cleaned.isEmpty) {
      return RecipeSuggestionsResult.empty();
    }

    final fallback = _fallbackRecipes(cleaned);

    try {
      final token = await AuthService.getAccessToken();
      final response = await http.post(
        Uri.parse('$_baseUrl/api/mealplan/recipes-by-ingredients'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'ingredients': cleaned,
          'maxRecipes': 4,
        }),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final parsed = _resultFromApi(decoded, cleaned, fallback);
        if (!parsed.isEmpty) {
          return parsed;
        }
      } else {
        developer.log('Ingredient recipe call failed: ${response.statusCode} ${response.body}');
      }
    } catch (error) {
      developer.log('Ingredient recipe call error: $error');
    }

    return RecipeSuggestionsResult(
      recipes: fallback,
      pantryMatches: fallback,
      ingredients: cleaned,
      source: 'local_fallback',
      fetchedAt: DateTime.now(),
    );
  }

  // Private helper methods
  static RecipeSuggestionsResult _resultFromApi(
    Map<String, dynamic> payload,
    List<String> requestedIngredients,
    List<Meal> fallback,
  ) {
    final recipes = _extractMealList(payload['recipes']);
    final pantryMatches = _extractMealList(payload['pantryMatches']);
    final source = payload['source']?.toString() ?? 'unknown';
    final providedIngredients = (payload['ingredients'] as List<dynamic>? ?? requestedIngredients)
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (recipes.isEmpty && pantryMatches.isEmpty) {
      return RecipeSuggestionsResult(
        recipes: fallback,
        pantryMatches: fallback,
        ingredients: providedIngredients.isNotEmpty ? providedIngredients : requestedIngredients,
        source: 'local_fallback',
        fetchedAt: DateTime.now(),
      );
    }

    return RecipeSuggestionsResult(
      recipes: recipes,
      pantryMatches: pantryMatches,
      ingredients: providedIngredients.isNotEmpty ? providedIngredients : requestedIngredients,
      source: source,
      fetchedAt: DateTime.now(),
    );
  }

  static List<Meal> _extractMealList(dynamic raw) {
    if (raw is! List) return const <Meal>[];
    return raw.map((item) => _recipeFromApi(item)).whereType<Meal>().toList();
  }

  static Meal? _recipeFromApi(dynamic payload) {
    if (payload is! Map<String, dynamic>) return null;
    final Map<String, dynamic> recipe = payload['recipe'] is Map
      ? Map<String, dynamic>.from(payload['recipe'] as Map)
      : <String, dynamic>{};
    final macrosSource = payload['macros'] ?? recipe['macros'];
    final macros = macrosSource is Map<String, dynamic>
        ? Map<String, dynamic>.from(macrosSource)
        : <String, dynamic>{};
    final tagSet = <String>{
      ..._stringListFrom(payload['tags']).map((tag) => tag.toLowerCase()),
      ..._stringListFrom(recipe['tags']).map((tag) => tag.toLowerCase()),
    };
    final primaryIngredients = _stringListFrom(payload['ingredients']);
    final recipeIngredients = _stringListFrom(recipe['ingredients']);
    final resolvedIngredients = primaryIngredients.isNotEmpty ? primaryIngredients : recipeIngredients;
    final primarySteps = _stringListFrom(payload['steps']);
    final instructionSteps = _stringListFrom(payload['instructions']);
    final recipeSteps = _stringListFrom(recipe['instructions']);
    final resolvedSteps = primarySteps.isNotEmpty
        ? primarySteps
        : (instructionSteps.isNotEmpty ? instructionSteps : recipeSteps);

    final category = payload['category']?.toString() ?? _slotFromTags(tagSet.toList()) ?? 'snack';
    final cookTime = payload['prepTime']?.toString() ??
        payload['cookTime']?.toString() ??
        recipe['cookTime']?.toString() ??
        '15 minutes';

    return Meal(
      id: payload['id']?.toString() ?? 'recipe_${DateTime.now().millisecondsSinceEpoch}',
      name: payload['title']?.toString() ?? payload['name']?.toString() ?? 'Pantry Recipe',
      category: category,
      calories: (payload['calories'] ?? macros['calories'] ?? 0).toInt(),
      protein: _asDouble(macros['protein'] ?? payload['protein']),
      carbs: _asDouble(macros['carbs'] ?? payload['carbs']),
      fat: _asDouble(macros['fat'] ?? payload['fat']),
      ingredients: resolvedIngredients,
      instructions: resolvedSteps.isNotEmpty
          ? resolvedSteps
          : const ['Combine ingredients, season well, and cook until fragrant.'],
      cookTime: cookTime,
      difficulty: payload['difficulty']?.toString() ?? 'Easy',
      cuisine: payload['cuisine']?.toString() ?? recipe['cuisine']?.toString() ?? 'Indian Fusion',
      isVegetarian: _asBool(payload['isVegetarian']) ||
          _asBool(recipe['isVegetarian']) ||
          (tagSet.contains('vegetarian') && !tagSet.contains('non_veg')),
      isVegan: _asBool(payload['isVegan']) || _asBool(recipe['isVegan']) || tagSet.contains('vegan'),
      createdAt: DateTime.now(),
    );
  }

  static String? _slotFromTags(List<String> tags) {
    if (tags.isEmpty) return null;
    final lower = tags.map((tag) => tag.toLowerCase()).toList();
    if (lower.any((tag) => tag.contains('breakfast'))) return 'breakfast';
    if (lower.any((tag) => tag.contains('lunch'))) return 'lunch';
    if (lower.any((tag) => tag.contains('dinner'))) return 'dinner';
    if (lower.any((tag) => tag.contains('snack'))) return 'snack';
    return null;
  }

  static List<Meal> _fallbackRecipes(List<String> ingredients) {
    final suggestions = <Meal>[];
    for (final meal in _sampleMeals) {
      final matches = ingredients.where((ingredient) =>
          meal.ingredients.any((mealIngredient) =>
              mealIngredient.toLowerCase().contains(ingredient.toLowerCase()))).length;
      if (matches > 0) {
        suggestions.add(meal);
      }
    }

    if (suggestions.isEmpty) {
      suggestions.addAll(_sampleMeals.take(2));
    }

    return suggestions;
  }

  static double _asDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      if (normalized == 'true' || normalized == '1' || normalized == 'yes') {
        return true;
      }
      if (normalized == 'false' || normalized == '0' || normalized == 'no') {
        return false;
      }
    }
    if (value is num) {
      return value != 0;
    }
    return false;
  }

  static List<String> _stringListFrom(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).map((item) => item.trim()).toList();
    }
    return const [];
  }
}
