import 'dart:convert';

class User {
  final String id;
  final String name;
  final int age;
  final double weight; // in kg
  final double height; // in cm
  final String gender;
  final String goal;
  final int targetCalories;
  final String dietPreference;
  final String language;
  final bool accessibilityMode;
  final List<String> healthConditions;
  final String activityLevel;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.targetCalories,
    required this.dietPreference,
    required this.language,
    required this.accessibilityMode,
    required this.healthConditions,
    required this.activityLevel,
    required this.createdAt,
  });

  // Calculate BMI
  double get bmi => weight / ((height / 100) * (height / 100));

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate BMR (Basal Metabolic Rate) using Harris-Benedict Formula
  double get bmr {
    if (gender.toLowerCase() == 'male') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  // Convert to JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'targetCalories': targetCalories,
      'dietPreference': dietPreference,
      'language': language,
      'accessibilityMode': accessibilityMode,
      'healthConditions': healthConditions,
      'activityLevel': activityLevel,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from JSON
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      gender: map['gender'] ?? '',
      goal: map['goal'] ?? '',
      targetCalories: map['targetCalories']?.toInt() ?? 2000,
      dietPreference: map['dietPreference'] ?? '',
      language: map['language'] ?? 'english',
      accessibilityMode: map['accessibilityMode'] ?? false,
      healthConditions: List<String>.from(map['healthConditions'] ?? []),
      activityLevel: map['activityLevel'] ?? 'sedentary',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    String? id,
    String? name,
    int? age,
    double? weight,
    double? height,
    String? gender,
    String? goal,
    int? targetCalories,
    String? dietPreference,
    String? language,
    bool? accessibilityMode,
    List<String>? healthConditions,
    String? activityLevel,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      targetCalories: targetCalories ?? this.targetCalories,
      dietPreference: dietPreference ?? this.dietPreference,
      language: language ?? this.language,
      accessibilityMode: accessibilityMode ?? this.accessibilityMode,
      healthConditions: healthConditions ?? this.healthConditions,
      activityLevel: activityLevel ?? this.activityLevel,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User(name: $name, age: $age, goal: $goal)';
  }
}
