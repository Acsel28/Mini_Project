class AiSmartSuggestion {
  AiSmartSuggestion({
    required this.title,
    required this.subtitle,
    required this.category,
    required this.tone,
    required this.refreshHint,
  });

  final String title;
  final String subtitle;
  final String category;
  final String tone;
  final String refreshHint;

  factory AiSmartSuggestion.fromJson(Map<String, dynamic> json) {
    return AiSmartSuggestion(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      category: json['category']?.toString() ?? 'insight',
      tone: json['tone']?.toString() ?? 'balanced',
      refreshHint: json['refresh_hint']?.toString() ?? '',
    );
  }
}

class AiTimelineEntry {
  AiTimelineEntry({
    required this.window,
    required this.label,
    required this.focus,
    required this.action,
  });

  final String window;
  final String label;
  final String focus;
  final String action;

  factory AiTimelineEntry.fromJson(Map<String, dynamic> json) {
    return AiTimelineEntry(
      window: json['window']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      focus: json['focus']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
    );
  }
}

class AiInsight {
  AiInsight({
    required this.title,
    required this.summary,
    required this.action,
    required this.category,
  });

  final String title;
  final String summary;
  final String action;
  final String category;

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      title: json['title']?.toString() ?? '',
      summary: json['summary']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      category: json['category']?.toString() ?? 'general',
    );
  }
}

class AiMacroStat {
  AiMacroStat({
    required this.label,
    required this.grams,
    required this.insight,
  });

  final String label;
  final double grams;
  final String insight;

  factory AiMacroStat.fromJson(Map<String, dynamic> json) {
    return AiMacroStat(
      label: json['label']?.toString() ?? '',
      grams: (json['grams'] as num?)?.toDouble() ?? 0,
      insight: json['insight']?.toString() ?? '',
    );
  }
}

class AiMacroBreakdown {
  AiMacroBreakdown({
    required this.headline,
    required this.calorieSummary,
    required this.macros,
    required this.callToAction,
  });

  final String headline;
  final String calorieSummary;
  final List<AiMacroStat> macros;
  final String callToAction;

  factory AiMacroBreakdown.fromJson(Map<String, dynamic> json) {
    final raw = json['macros'] as List<dynamic>? ?? const [];
    return AiMacroBreakdown(
      headline: json['headline']?.toString() ?? '',
      calorieSummary: json['calorie_summary']?.toString() ?? '',
      callToAction: json['call_to_action']?.toString() ?? '',
      macros: raw.map((item) => AiMacroStat.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class AiCuratedMealNote {
  AiCuratedMealNote({
    required this.mealType,
    required this.highlight,
    required this.reason,
    required this.calories,
    required this.macros,
    required this.tags,
  });

  final String mealType;
  final String highlight;
  final String reason;
  final int calories;
  final Map<String, double> macros;
  final List<String> tags;

  factory AiCuratedMealNote.fromJson(Map<String, dynamic> json) {
    final macroMap = (json['macros'] as Map<String, dynamic>?) ?? const {};
    return AiCuratedMealNote(
      mealType: json['meal_type']?.toString() ?? 'meal',
      highlight: json['highlight']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      calories: json['calories'] is num ? (json['calories'] as num).toInt() : 0,
      macros: macroMap.map((key, value) => MapEntry(key, (value as num).toDouble())),
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

class MealStudioIdea {
  MealStudioIdea({
    required this.name,
    required this.description,
    required this.calories,
    required this.macros,
    required this.tags,
    required this.steps,
  });

  final String name;
  final String description;
  final int calories;
  final Map<String, double> macros;
  final List<String> tags;
  final List<String> steps;

  factory MealStudioIdea.fromJson(Map<String, dynamic> json) {
    final macroMap = (json['macros'] as Map<String, dynamic>?) ?? const {};
    return MealStudioIdea(
      name: json['name']?.toString() ?? 'Chef pick',
      description: json['description']?.toString() ?? '',
      calories: json['calories'] is num ? (json['calories'] as num).toInt() : 0,
      macros: macroMap.map((key, value) => MapEntry(key, (value as num).toDouble())),
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      steps: (json['steps'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    );
  }
}

class AiWeekPlanDay {
  AiWeekPlanDay({
    required this.day,
    required this.headline,
    required this.focus,
    required this.anchors,
    required this.mealTheme,
  });

  final String day;
  final String headline;
  final String focus;
  final List<String> anchors;
  final String mealTheme;

  factory AiWeekPlanDay.fromJson(Map<String, dynamic> json) {
    return AiWeekPlanDay(
      day: json['day']?.toString() ?? '',
      headline: json['headline']?.toString() ?? '',
      focus: json['focus']?.toString() ?? '',
      anchors: (json['anchors'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      mealTheme: json['meal_theme']?.toString() ?? '',
    );
  }
}
