import 'dart:convert';

class Meal {
  final String id;
  final String name;
  final String category; // breakfast, lunch, dinner, snacks
  final int calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final List<String> ingredients;
  final List<String> instructions;
  final String cookTime;
  final String difficulty; // Easy, Medium, Hard
  final String cuisine; // Indian, Chinese, Continental, etc.
  final bool isVegetarian;
  final bool isVegan;
  final DateTime createdAt;

  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
    required this.cookTime,
    this.difficulty = 'Easy',
    this.cuisine = 'General',
    this.isVegetarian = true,
    this.isVegan = false,
    required this.createdAt,
  });

  // Calculate protein percentage
  double get proteinPercentage => (protein * 4) / calories * 100;

  // Calculate carbs percentage
  double get carbsPercentage => (carbs * 4) / calories * 100;

  // Calculate fat percentage
  double get fatPercentage => (fat * 9) / calories * 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookTime': cookTime,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      calories: map['calories']?.toInt() ?? 0,
      protein: map['protein']?.toDouble() ?? 0.0,
      carbs: map['carbs']?.toDouble() ?? 0.0,
      fat: map['fat']?.toDouble() ?? 0.0,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      cookTime: map['cookTime'] ?? '',
      difficulty: map['difficulty'] ?? 'Easy',
      cuisine: map['cuisine'] ?? 'General',
      isVegetarian: map['isVegetarian'] ?? true,
      isVegan: map['isVegan'] ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory Meal.fromJson(String source) => Meal.fromMap(json.decode(source));
}

// Daily Meal Plan
class MealPlan {
  final String id;
  final DateTime date;
  final Meal? breakfast;
  final Meal? lunch;
  final Meal? dinner;
  final List<Meal> snacks;
  final num totalCalories; // <-- changed from int to num
  final double totalProtein;
  final double totalCarbs;
  final double totalFat;

  const MealPlan({
    required this.id,
    required this.date,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks = const [],
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFat,
  });

  // Calculate totals from meals
  factory MealPlan.fromMeals({
    required String id,
    required DateTime date,
    Meal? breakfast,
    Meal? lunch,
    Meal? dinner,
    List<Meal>? snacks,
  }) {
    final allMeals = [
      if (breakfast != null) breakfast,
      if (lunch != null) lunch,
      if (dinner != null) dinner,
      ...(snacks ?? []),
    ];

    final totalCalories = allMeals.fold<num>(0, (sum, meal) => sum + meal.calories);
    final totalProtein = allMeals.fold<double>(0, (sum, meal) => sum + meal.protein);
    final totalCarbs = allMeals.fold<double>(0, (sum, meal) => sum + meal.carbs);
    final totalFat = allMeals.fold<double>(0, (sum, meal) => sum + meal.fat);

    return MealPlan(
      id: id,
      date: date,
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
      snacks: snacks ?? [],
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFat: totalFat,
    );
  }
}
