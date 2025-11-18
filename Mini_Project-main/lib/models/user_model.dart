import 'dart:convert';

class User {
  final String id;
  final String email;
  final String name;
  final int age;
  final String gender;

  final double height;        // height_cm
  final double weight;        // weight_kg
  final String language;      
  final int targetCalories;

  // Disease/Health info
  final String? disease;       // disease name (e.g., "PCOS", "Diabetes Type 2")
  final String? disease_key;   // disease keyname (e.g., "pcos", "diabetes_type2")
  final String? disease_profile_id;

  // Diet & Nutrition Preferences
  final String? dietPreference;     // vegetarian, vegan, etc.
  final String? mealType;           // balanced, high_protein, etc.
  final String? allergies;          // user allergies/dietary restrictions

  // Fitness & Activity
  final String? fitnessGoal;        // weight_loss, muscle_gain, etc.
  final String? activityLevel;      // sedentary, lightly_active, etc.

  // extra fields used ONLY by UI
  final String goal;
  final bool accessibilityMode;
  final List<String> healthConditions;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.language,
    required this.targetCalories,
    this.disease,
    this.disease_key,
    this.disease_profile_id,
    this.dietPreference,
    this.mealType,
    this.allergies,
    this.fitnessGoal,
    this.activityLevel,

    required this.goal,
    required this.accessibilityMode,
    required this.healthConditions,
  });

  // BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // BMR
  double get bmr {
    if (gender == "male") {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map["id"] ?? "",
      email: map["email"] ?? "",
      name: map["name"] ?? "",
      age: map["age"] ?? 0,
      gender: map["gender"] ?? "",
      height: (map["height_cm"] ?? map["height"] ?? 0).toDouble(),
      weight: (map["weight_kg"] ?? map["weight"] ?? 0).toDouble(),
      language: map["language"] ?? "english",
      targetCalories:
          map["target_calories"] ?? map["targetCalories"] ?? 2000,
      disease: map["disease"],
      disease_key: map["disease_key"],
      disease_profile_id: map["disease_profile_id"],

      // Diet & Nutrition
      dietPreference: map["diet_preference"] ?? map["dietPreference"],
      mealType: map["meal_type"],
      allergies: map["allergies"],

      // Fitness & Activity
      fitnessGoal: map["fitness_goal"],
      activityLevel: map["activity_level"] ?? "moderately_active",

      // UI-only fallback values
      goal: map["goal"] ?? "healthy_eating",
      accessibilityMode: map["accessibilityMode"] ?? false,
      healthConditions:
          List<String>.from(map["healthConditions"] ?? []),
    );
  }

  factory User.fromJson(String jsonStr) =>
      User.fromMap(jsonDecode(jsonStr));

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "email": email,
      "name": name,
      "age": age,
      "gender": gender,
      "height_cm": height,
      "weight_kg": weight,
      "language": language,
      "target_calories": targetCalories,
      "disease": disease,
      "disease_key": disease_key,
      "disease_profile_id": disease_profile_id,

      "diet_preference": dietPreference,
      "meal_type": mealType,
      "allergies": allergies,
      "fitness_goal": fitnessGoal,
      "activity_level": activityLevel,

      "goal": goal,
      "accessibilityMode": accessibilityMode,
      "healthConditions": healthConditions,
    };
  }

  String toJson() => jsonEncode(toMap());
}
