import 'dart:math';
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
  static Future<MealPlan> getDailyMealPlan(User user) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final filteredMeals = _filterMealsByDiet(_sampleMeals, user.dietPreference);

    final breakfast = _selectMealByCategory(filteredMeals, 'breakfast');
    final lunch = _selectMealByCategory(filteredMeals, 'lunch');
    final dinner = _selectMealByCategory(filteredMeals, 'dinner');

    return MealPlan.fromMeals(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );
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
  static List<Meal> _filterMealsByDiet(List<Meal> meals, String dietPreference) {
    switch (dietPreference.toLowerCase()) {
      case 'vegetarian':
        return meals.where((meal) => meal.isVegetarian).toList();
      case 'vegan':
        return meals.where((meal) => meal.isVegan).toList();
      default:
        return meals;
    }
  }

  static Meal? _selectMealByCategory(List<Meal> meals, String category) {
    final categoryMeals = meals.where((meal) => meal.category == category).toList();
    if (categoryMeals.isEmpty) return null;

    final random = Random();
    return categoryMeals[random.nextInt(categoryMeals.length)];
  }
}
