class AppConstants {
  // App Info
  static const String appName = 'AI Diet App';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String languageKey = 'selected_language';
  static const String accessibilityModeKey = 'accessibility_mode';

  // Calorie & Macro Constants
  static const int defaultDailyCalories = 2000;
  static const double proteinPercentage = 0.25; // 25% of calories
  static const double carbsPercentage = 0.50;   // 50% of calories
  static const double fatPercentage = 0.25;     // 25% of calories

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
}

// Health Goals
enum HealthGoal {
  weightLoss,
  weightGain,
  muscleGain,
  maintenance,
  healthyEating,
}

// Dietary Preferences
enum DietType {
  vegetarian,
  vegan,
  nonVegetarian,
  keto,
  paleo,
}

// Activity Levels
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive,
}
