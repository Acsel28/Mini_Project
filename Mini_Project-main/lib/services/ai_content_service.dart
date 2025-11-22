import 'dart:convert';

import '../models/ai_content_models.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import 'groq_service.dart';

class AiContentService {
  static Future<List<AiSmartSuggestion>> fetchSmartSuggestions({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''You are a proactive nutrition mentor. Using the context below, craft three forward-looking nudges that feel bespoke to the user. Keep each suggestion specific, referencing biomarkers, habits, or upcoming meals.
Return STRICT JSON:
{
  "suggestions": [
    {
      "title": "",
      "subtitle": "",
      "category": "chef|mindfulness|insight|recovery",
      "tone": "bold|gentle|urgent|celebratory",
      "refresh_hint": "why this insight is fresh today"
    }
  ]
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.85);
    final suggestions = response?['suggestions'] as List<dynamic>?;
    if (suggestions == null || suggestions.isEmpty) {
      return _fallbackSmartSuggestions();
    }
    return suggestions
        .map((item) => AiSmartSuggestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AiTimelineEntry>> fetchMealTimeline({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''Design a metabolic timeline for the user. Break the day into 4-5 windows with precise fueling or mindfulness actions tied to the supplied plan. Keep text concise.
Return STRICT JSON:
{
  "timeline": [
    {
      "window": "06:00-08:30",
      "label": "Stabilize morning glucose",
      "focus": "Protein-forward breakfast",
      "action": "Sip warm water with lemon, then enjoy the oat bowl within 30 min of waking"
    }
  ]
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.65);
    final timeline = response?['timeline'] as List<dynamic>?;
    if (timeline == null || timeline.isEmpty) {
      return _fallbackTimeline();
    }
    return timeline.map((item) => AiTimelineEntry.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<AiInsight>> fetchHealthInsights({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''Generate three health insights blending nutrition, recovery, and mindset. Base them on the context and make them actionable within the next 12 hours.
Return STRICT JSON:
{
  "insights": [
    {
      "title": "",
      "summary": "",
      "action": "",
      "category": "biomarker|mindset|movement|hydration"
    }
  ]
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.7);
    final insights = response?['insights'] as List<dynamic>?;
    if (insights == null || insights.isEmpty) {
      return _fallbackInsights();
    }
    return insights.map((item) => AiInsight.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<AiMacroBreakdown?> fetchMacroBreakdown({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''Analyze the supplied macro totals and craft a concise narrative about calorie balance. Focus on what is trending high/low and what action to take at the next meal.
Return STRICT JSON:
{
  "headline": "",
  "calorie_summary": "",
  "macros": [
    {"label": "Protein", "grams": 110, "insight": "On target"}
  ],
  "call_to_action": ""
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.55);
    if (response == null) {
      return _fallbackMacroBreakdown();
    }
    return AiMacroBreakdown.fromJson(response);
  }

  static Future<List<AiCuratedMealNote>> fetchCuratedMealNotes({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''Write a short reason for each curated meal explaining why it fits the plan. Include a highlight, calorie reminder, macro recap, and 1-2 descriptive tags.
Return STRICT JSON:
{
  "meals": [
    {
      "meal_type": "breakfast",
      "highlight": "",
      "reason": "",
      "calories": 400,
      "macros": {"protein": 25, "carbs": 40, "fat": 12},
      "tags": ["low_gi", "gut_healing"]
    }
  ]
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.7);
    final meals = response?['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return _fallbackCuratedNotes();
    }
    return meals.map((item) => AiCuratedMealNote.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<MealStudioIdea>> fetchMealStudioIdeas({
    required String mealType,
    User? user,
  }) async {
    final payload = jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'meal_type': mealType,
      'user': _userPayload(user),
    });
    final prompt = '''You are an inventive chef. Generate three ${mealType.toUpperCase()} options tuned to the user. Provide calories, macro grams, short description, helpful tags, and up to 3 prep steps.
Return STRICT JSON:
{
  "ideas": [
    {
      "name": "",
      "description": "",
      "calories": 0,
      "macros": {"protein": 0, "carbs": 0, "fat": 0},
      "tags": ["gluten_free"],
      "steps": ["toast seeds", "blend smoothie"]
    }
  ]
}
Context: $payload''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.9);
    final ideas = response?['ideas'] as List<dynamic>?;
    if (ideas == null || ideas.isEmpty) {
      return _fallbackMealIdeas(mealType);
    }
    return ideas.map((item) => MealStudioIdea.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<AiWeekPlanDay>> fetchWeeklyPlan({
    User? user,
    MealPlan? mealPlan,
  }) async {
    final prompt = '''Design a 7-day accountability rhythm for the user. Each day needs a headline, one-line focus, 2-3 anchor actions (morning/midday/evening), and a meal theme. Keep it short for mobile surfaces.
Return STRICT JSON:
{
  "week": [
    {
      "day": "Mon",
      "headline": "Metabolic reset",
      "focus": "Protein-first breakfast, caffeine cut by 2 PM.",
      "anchors": ["AM: Warm water + electrolytes", "Mid: Walk after lunch", "PM: Box breathing"],
      "meal_theme": "High-fiber reboot"
    }
  ]
}
Context: ${_buildContext(user, mealPlan)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.6);
    final week = response?['week'] as List<dynamic>?;
    if (week == null || week.isEmpty) {
      return _fallbackWeeklyPlan();
    }
    return week.map((item) => AiWeekPlanDay.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<String> getCoachResponse({
    required String userMessage,
    required List<Map<String, String>> history,
    User? user,
  }) async {
    final conversation = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'Act as a compassionate nutrition coach. Reply conversationally (max 120 words), reference prior context, and finish with a concrete action.',
      },
      ...history
          .map((entry) {
            final role = entry['role'];
            final text = entry['message'] ?? entry['content'] ?? '';
            if (text.isEmpty) return null;
            final openAiRole = role == 'coach' ? 'assistant' : 'user';
            return {'role': openAiRole, 'content': text};
          })
          .whereType<Map<String, String>>()
          .toList(),
      {'role': 'user', 'content': userMessage},
    ];

    final reply = await GroqService.conversationalResponse(
      messages: conversation,
      temperature: 0.8,
      maxTokens: 350,
    );

    return reply ?? 'I am still thinking, try again in a moment.';
  }

  static String _buildContext(User? user, MealPlan? mealPlan) {
    return jsonEncode({
      'timestamp': DateTime.now().toIso8601String(),
      'user': _userPayload(user),
      'meal_plan': _mealPlanPayload(mealPlan),
    });
  }

  static Map<String, dynamic> _userPayload(User? user) {
    if (user == null) return {};
    return {
      'name': user.name,
      'age': user.age,
      'gender': user.gender,
      'diet_preference': user.dietPreference,
      'fitness_goal': user.fitnessGoal,
      'activity_level': user.activityLevel,
      'disease': user.disease,
      'target_calories': user.targetCalories,
      'weight_kg': user.weight,
      'height_cm': user.height,
      'health_conditions': user.healthConditions,
    };
  }

  static Map<String, dynamic> _mealPlanPayload(MealPlan? mealPlan) {
    if (mealPlan == null) {
      return {
        'date': DateTime.now().toIso8601String(),
        'totals': {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
        },
        'meals': const {},
      };
    }
    return {
      'date': mealPlan.date.toIso8601String(),
      'totals': {
        'calories': mealPlan.totalCalories,
        'protein': mealPlan.totalProtein,
        'carbs': mealPlan.totalCarbs,
        'fat': mealPlan.totalFat,
      },
      'meals': {
        'breakfast': _mealPayload(mealPlan.breakfast),
        'lunch': _mealPayload(mealPlan.lunch),
        'dinner': _mealPayload(mealPlan.dinner),
        'snacks': mealPlan.snacks.map(_mealPayload).toList(),
      },
    };
  }

  static Map<String, dynamic>? _mealPayload(Meal? meal) {
    if (meal == null) return null;
    return {
      'name': meal.name,
      'category': meal.category,
      'calories': meal.calories,
      'protein': meal.protein,
      'carbs': meal.carbs,
      'fat': meal.fat,
      'cuisine': meal.cuisine,
      'ingredients': meal.ingredients,
    };
  }

  static List<AiSmartSuggestion> _fallbackSmartSuggestions() => [
        AiSmartSuggestion(
          title: 'Front-load hydration',
          subtitle: 'Sip 400 ml of water with electrolytes before breakfast.',
          category: 'mindfulness',
          tone: 'gentle',
          refreshHint: 'Keeps cortisol spikes in check for the morning block.',
        ),
        AiSmartSuggestion(
          title: 'Protein-first lunch',
          subtitle: 'Add 1 palm of tofu or paneer before grains.',
          category: 'chef',
          tone: 'bold',
          refreshHint: 'Stabilizes glucose for your 3 PM slump.',
        ),
        AiSmartSuggestion(
          title: 'Micro-mobility alarm',
          subtitle: 'Walk 5 minutes after each meal today.',
          category: 'insight',
          tone: 'celebratory',
          refreshHint: 'Improves insulin sensitivity within 48 hours.',
        ),
      ];

  static List<AiTimelineEntry> _fallbackTimeline() => [
        AiTimelineEntry(
          window: '06:30 - 08:00',
          label: 'Wake & prime',
          focus: 'Hydration + sunlight',
          action: 'Warm water with lemon, 5-minute stretch by a window.',
        ),
        AiTimelineEntry(
          window: '12:00 - 14:00',
          label: 'Focused lunch',
          focus: 'Protein + colorful carbs',
          action: 'Half plate veggies, quarter plate grains, healthy fat drizzle.',
        ),
        AiTimelineEntry(
          window: '16:00 - 17:00',
          label: 'Glucose guardrail',
          focus: 'Targeted snack',
          action: 'Handful of nuts + fruit, followed by 10 squats.',
        ),
        AiTimelineEntry(
          window: '20:00 - 21:30',
          label: 'Wind-down ritual',
          focus: 'Light dinner + nervous-system reset',
          action: 'Herbal tea, blue-light block, jot tomorrow’s wins.',
        ),
      ];

  static List<AiInsight> _fallbackInsights() => [
        AiInsight(
          title: 'Hydration debt is building',
          summary: 'You covered only 40% of your water target yesterday.',
          action: 'Front-load 1 bottle before noon today.',
          category: 'hydration',
        ),
        AiInsight(
          title: 'Protein pacing working',
          summary: 'Breakfast + lunch already hit 55g of protein.',
          action: 'Anchor dinner with 25g more to solidify recovery.',
          category: 'biomarker',
        ),
        AiInsight(
          title: 'Mindset mini-reset',
          summary: 'Sleep data shows racing thoughts past 10 PM.',
          action: 'Try box breathing for 2 minutes when you close the laptop.',
          category: 'mindset',
        ),
      ];

  static AiMacroBreakdown _fallbackMacroBreakdown() => AiMacroBreakdown(
        headline: 'Calories slightly below target',
        calorieSummary: 'You are trending ~180 kcal below the personalized maintenance range.',
        macros: [
          AiMacroStat(label: 'Protein', grams: 92, insight: 'Room for +20g to support recovery'),
          AiMacroStat(label: 'Carbs', grams: 165, insight: 'On track—mostly complex sources'),
          AiMacroStat(label: 'Fat', grams: 58, insight: 'Stay under 70g to keep digestion light at night'),
        ],
        callToAction: 'Add a Greek yogurt parfait or lentil soup at dinner to close the gap.',
      );

  static List<AiCuratedMealNote> _fallbackCuratedNotes() => [
        AiCuratedMealNote(
          mealType: 'breakfast',
          highlight: 'Fiber-first chia oats',
          reason: 'Balances hormones with omega-3s and steady carbs.',
          calories: 410,
          macros: const {'protein': 22.0, 'carbs': 48.0, 'fat': 14.0},
          tags: const ['hormone_health', 'gut_support'],
        ),
        AiCuratedMealNote(
          mealType: 'lunch',
          highlight: 'Rainbow buddha bowl',
          reason: 'Loads polyphenols to calm inflammation post-workout.',
          calories: 520,
          macros: const {'protein': 28.0, 'carbs': 55.0, 'fat': 18.0},
          tags: const ['anti_inflammatory', 'plant_forward'],
        ),
        AiCuratedMealNote(
          mealType: 'dinner',
          highlight: 'Ginger miso soup + tofu',
          reason: 'Light on the gut but rich in minerals for sleep quality.',
          calories: 430,
          macros: const {'protein': 32.0, 'carbs': 30.0, 'fat': 16.0},
          tags: const ['sleep_support', 'immune_ready'],
        ),
      ];

  static List<MealStudioIdea> _fallbackMealIdeas(String mealType) {
    final label = mealType[0].toUpperCase() + mealType.substring(1);
    return [
      MealStudioIdea(
        name: '$label power bowl',
        description: 'Layered greens, roasted veggies, ancient grains, and tahini drizzle.',
        calories: 480,
        macros: const {'protein': 28.0, 'carbs': 52.0, 'fat': 18.0},
        tags: const ['high_fiber', 'anti_inflammatory'],
        steps: const ['Roast veggies', 'Cook grains', 'Assemble + drizzle sauce'],
      ),
      MealStudioIdea(
        name: '$label reset smoothie',
        description: 'Spinach, frozen berries, pea protein, chia, and coconut water.',
        calories: 310,
        macros: const {'protein': 24.0, 'carbs': 36.0, 'fat': 9.0},
        tags: const ['recovery', 'quick'],
        steps: const ['Add all ingredients', 'Blend until creamy'],
      ),
      MealStudioIdea(
        name: '$label tempeh tacos',
        description: 'Crispy tempeh, citrus slaw, avocado crema in corn tortillas.',
        calories: 540,
        macros: const {'protein': 30.0, 'carbs': 50.0, 'fat': 22.0},
        tags: const ['gut_health', 'high_protein'],
        steps: const ['Crumble + sear tempeh', 'Mix slaw', 'Build tacos'],
      ),
    ];
  }

  static List<AiWeekPlanDay> _fallbackWeeklyPlan() => [
        AiWeekPlanDay(
          day: 'Mon',
          headline: 'Metabolic reboot',
          focus: 'Hydration and protein pacing to flatten glucose spikes.',
          mealTheme: 'Protein-forward breakfasts',
          anchors: const [
            'AM: 400ml mineral water + sunlight stroll',
            'Mid: Add lentils or tofu before grains',
            'PM: 5-min diaphragmatic breathing before bed',
          ],
        ),
        AiWeekPlanDay(
          day: 'Tue',
          headline: 'Micronutrient top-up',
          focus: 'Color-heavy plates to refill antioxidants for joint recovery.',
          mealTheme: 'Rainbow bowls',
          anchors: const [
            'AM: Berries + chia with breakfast',
            'Mid: Walk phone calls to boost NEAT',
            'PM: Magnesium-rich soup',
          ],
        ),
        AiWeekPlanDay(
          day: 'Wed',
          headline: 'Glucose guardrail',
          focus: 'Fiber-first sequencing and micro-movement after meals.',
          mealTheme: 'Fiber stacking',
          anchors: const [
            'AM: 1 tbsp flax before coffee',
            'Mid: 8-min incline walk post lunch',
            'PM: Herbal tea swap for dessert',
          ],
        ),
        AiWeekPlanDay(
          day: 'Thu',
          headline: 'Nervous-system calm',
          focus: 'Light meals and breath cues to lower evening cortisol.',
          mealTheme: 'Light digestion',
          anchors: const [
            'AM: Box breathing before stand-up',
            'Mid: Add fermented veggies at lunch',
            'PM: Digital sunset 60 mins pre-sleep',
          ],
        ),
        AiWeekPlanDay(
          day: 'Fri',
          headline: 'Strength primer',
          focus: 'Fuel lifts with steady carbs + electrolytes.',
          mealTheme: 'Performance carbs',
          anchors: const [
            'AM: Warm-up mobility + creatine',
            'Mid: Sweet potato or quinoa base',
            'PM: Protein shake within 30 mins of workout',
          ],
        ),
        AiWeekPlanDay(
          day: 'Sat',
          headline: 'Recovery + play',
          focus: 'Flexible meals but keep hydration + sleep anchors.',
          mealTheme: 'Adventure-friendly meals',
          anchors: const [
            'AM: Electrolyte mocktail before outings',
            'Mid: Shareable platter with lean protein',
            'PM: Epsom salt soak or foam rolling',
          ],
        ),
        AiWeekPlanDay(
          day: 'Sun',
          headline: 'Reset + prep',
          focus: 'Lower inflammatory load and prep for Monday.',
          mealTheme: 'Batch-cooked staples',
          anchors: const [
            'AM: Journaling + sunlight exposure',
            'Mid: Slow cooker soup or stew',
            'PM: Plan groceries + gratitude list',
          ],
        ),
      ];
}
