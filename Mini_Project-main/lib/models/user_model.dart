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

  // extra fields used ONLY by UI
  final String goal;
  final String dietPreference;
  final bool accessibilityMode;
  final List<String> healthConditions;
  final String activityLevel;

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

    required this.goal,
    required this.dietPreference,
    required this.accessibilityMode,
    required this.healthConditions,
    required this.activityLevel,
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

      // UI-only fallback values
      goal: map["goal"] ?? "healthy_eating",
      dietPreference: map["dietPreference"] ?? "vegetarian",
      accessibilityMode: map["accessibilityMode"] ?? false,
      healthConditions:
          List<String>.from(map["healthConditions"] ?? []),
      activityLevel:
          map["activityLevel"] ?? "moderately_active",
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

      "goal": goal,
      "dietPreference": dietPreference,
      "accessibilityMode": accessibilityMode,
      "healthConditions": healthConditions,
      "activityLevel": activityLevel,
    };
  }

  String toJson() => jsonEncode(toMap());
}
