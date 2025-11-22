import 'dart:developer' as developer;

import 'mealplan_service.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';

class MealService {
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
  static Future<List<Meal>> getRecipesByIngredients(List<String> ingredients) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final suggestions = <Meal>[];

    for (final meal in _sampleMeals) {
      final matchingIngredients = ingredients.where(
        (ingredient) => meal.ingredients.any(
          (mealIngredient) => mealIngredient.toLowerCase().contains(ingredient.toLowerCase())
        )
      ).length;

      if (matchingIngredients > 0) {
        suggestions.add(meal);
      }
    }

    if (suggestions.isEmpty) {
      suggestions.addAll(_sampleMeals.take(2));
    }

    return suggestions;
  }

  // Private helper methods
}
