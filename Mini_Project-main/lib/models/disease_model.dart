class Disease {
  final String id;
  final String keyname;
  final String title;
  final String description;
  final String? rulesJson;

  Disease({
    required this.id,
    required this.keyname,
    required this.title,
    required this.description,
    this.rulesJson,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      id: json['id'] ?? '',
      keyname: json['keyname'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      rulesJson: json['rules_json'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'keyname': keyname,
      'title': title,
      'description': description,
      'rules_json': rulesJson,
    };
  }
}

class DietInfo {
  final List<String> avoidFoods;
  final List<String> recommendedFoods;
  final Map<String, dynamic> constraints;
  final Map<String, dynamic> macros;

  DietInfo({
    required this.avoidFoods,
    required this.recommendedFoods,
    required this.constraints,
    required this.macros,
  });

  factory DietInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return DietInfo(
        avoidFoods: [],
        recommendedFoods: [],
        constraints: {},
        macros: {},
      );
    }
    return DietInfo(
      avoidFoods: List<String>.from(json['avoid_foods'] ?? []),
      recommendedFoods: List<String>.from(json['recommended_foods'] ?? []),
      constraints: json['constraints'] ?? {},
      macros: json['macros'] ?? {},
    );
  }

  String getSummary() {
    final summaryParts = <String>[];
    
    if (constraints['focus'] != null) {
      summaryParts.add('Focus: ${constraints['focus']}');
    }
    if (constraints['sodium_limit_mg'] != null) {
      summaryParts.add('Sodium: ${constraints['sodium_limit_mg']}mg/day');
    }
    if (constraints['max_daily_sugar_g'] != null) {
      summaryParts.add('Max sugar: ${constraints['max_daily_sugar_g']}g/day');
    }
    if (constraints['meal_frequency'] != null) {
      summaryParts.add('Meals: ${constraints['meal_frequency']}');
    }
    
    return summaryParts.isNotEmpty ? summaryParts.join(' | ') : 'Balanced nutrition recommended';
  }
}

class Exercise {
  final String id;
  final String name;
  final String difficulty;
  final String? equipment;
  final List<String> steps;
  final List<String> contraindications;
  final List<String> muscles;
  final String? demoVideoUrl;

  Exercise({
    required this.id,
    required this.name,
    required this.difficulty,
    this.equipment,
    this.steps = const [],
    this.contraindications = const [],
    this.muscles = const [],
    this.demoVideoUrl,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      difficulty: json['difficulty'] ?? 'beginner',
      equipment: json['equipment'],
      steps: List<String>.from(json['steps'] ?? []),
      contraindications: List<String>.from(json['contraindications'] ?? []),
      muscles: List<String>.from(json['muscles'] ?? []),
      demoVideoUrl: json['demo_video_url'],
    );
  }
}

class ExerciseRecommendations {
  final List<Exercise> recommendedExercises;
  final List<Exercise> exercisesToAvoid;
  final Map<String, dynamic> warnings;

  ExerciseRecommendations({
    required this.recommendedExercises,
    required this.exercisesToAvoid,
    required this.warnings,
  });

  factory ExerciseRecommendations.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ExerciseRecommendations(
        recommendedExercises: [],
        exercisesToAvoid: [],
        warnings: {},
      );
    }
    return ExerciseRecommendations(
      recommendedExercises: (json['recommended'] as List?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      exercisesToAvoid: (json['avoid'] as List?)
              ?.map((e) => Exercise.fromJson(e))
              .toList() ??
          [],
      warnings: json['warnings'] ?? {},
    );
  }

  String getSummary() {
    final parts = <String>[];
    if (recommendedExercises.isNotEmpty) {
      parts.add('${recommendedExercises.length} recommended exercises');
    }
    if (exercisesToAvoid.isNotEmpty) {
      parts.add('${exercisesToAvoid.length} exercises to avoid');
    }
    return parts.isNotEmpty ? parts.join(' | ') : 'Exercise guidance available';
  }
}

class LifestyleGuidance {
  final List<String> tips;
  final MonitoringGuidelines monitoring;
  final Map<String, dynamic> resources;

  LifestyleGuidance({
    required this.tips,
    required this.monitoring,
    required this.resources,
  });

  factory LifestyleGuidance.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return LifestyleGuidance(
        tips: [],
        monitoring: MonitoringGuidelines.empty(),
        resources: {},
      );
    }
    return LifestyleGuidance(
      tips: List<String>.from(json['tips'] ?? []),
      monitoring: MonitoringGuidelines.fromJson(json['monitoring']),
      resources: json['resources'] ?? {},
    );
  }
}

class MonitoringGuidelines {
  final String frequency;
  final List<String> trackingPoints;
  final List<String> whenToContactDoctor;

  MonitoringGuidelines({
    required this.frequency,
    required this.trackingPoints,
    required this.whenToContactDoctor,
  });

  factory MonitoringGuidelines.empty() {
    return MonitoringGuidelines(
      frequency: 'As recommended by healthcare provider',
      trackingPoints: [],
      whenToContactDoctor: [],
    );
  }

  factory MonitoringGuidelines.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return MonitoringGuidelines.empty();
    }
    return MonitoringGuidelines(
      frequency: json['frequency'] ?? 'As recommended by healthcare provider',
      trackingPoints: List<String>.from(json['trackingPoints'] ?? []),
      whenToContactDoctor: List<String>.from(json['when_to_contact_doctor'] ?? []),
    );
  }
}

class FullDiseaseProfile {
  final Disease disease;
  final DietInfo? diet;
  final ExerciseRecommendations? exercise;
  final LifestyleGuidance lifestyle;

  FullDiseaseProfile({
    required this.disease,
    required this.diet,
    required this.exercise,
    required this.lifestyle,
  });

  factory FullDiseaseProfile.fromJson(Map<String, dynamic> json) {
    return FullDiseaseProfile(
      disease: Disease.fromJson(json['disease'] ?? {}),
      diet: json['diet'] != null ? DietInfo.fromJson(json['diet']) : null,
      exercise: json['exercise'] != null
          ? ExerciseRecommendations.fromJson(json['exercise'])
          : null,
      lifestyle: LifestyleGuidance.fromJson(json['lifestyle']),
    );
  }

  String getMainFocus() {
    if (diet != null) {
      final focus = diet!.constraints['focus'];
      if (focus != null) return focus;
    }
    return 'Comprehensive health management';
  }
}

class DiseaseDetailsResponse {
  final String id;
  final String keyname;
  final String title;
  final String description;
  final DietInfo? diet;
  final ExerciseRecommendations? exercises;
  final Map<String, dynamic> recommendations;

  DiseaseDetailsResponse({
    required this.id,
    required this.keyname,
    required this.title,
    required this.description,
    required this.diet,
    required this.exercises,
    required this.recommendations,
  });

  factory DiseaseDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DiseaseDetailsResponse(
      id: json['id'] ?? '',
      keyname: json['keyname'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      diet: json['diet'] != null ? DietInfo.fromJson(json['diet']) : null,
      exercises: json['exercises'] != null
          ? ExerciseRecommendations.fromJson(json['exercises'])
          : null,
      recommendations: json['recommendations'] ?? {},
    );
  }
}
