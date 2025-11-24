import 'dart:convert';

import '../models/ai_content_models.dart';
import '../models/meal_model.dart';
import '../models/user_model.dart';
import '../utils/language_utils.dart';
import 'groq_service.dart';

const String _indiaCultureGuardrails = '''Cultural guardrails:
- Keep every recommendation rooted in everyday Indian households (think dal, roti, sabzi, poha, upma, idli, millets, curd rice, seasonal fruits, chutneys).
- Prefer affordable pantry staples, street-side snacks made healthier, and vegetarian-friendly protein like dal, sprouts, paneer, curd, and millets; non-veg options should be basic (eggs, fish curry) rather than gourmet.
- When suggesting movement or recovery, weave in yoga flows, pranayama, surya namaskar, brisk terrace walks, or light bodyweight drills that can be done in a small apartment.
- Mindset and tone should feel like a caring Indian coach speaking to a middle-class family juggling work, commute, and elders at home; celebrate small wins and avoid fancy jargon.
- Use Indian measurements or references (glass of water, katori, ladle, pressure cooker whistle) when helpful.''';

String _languageDirective(String? language) {
  return isHindiLanguage(language)
      ? 'Respond entirely in conversational Hindi using Devanagari script while keeping numerals as digits.'
      : 'Respond in clear Indian English with short, action-focused sentences.';
}

class AiContentService {
  static Future<List<AiSmartSuggestion>> fetchSmartSuggestions({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.85);
    final suggestions = response?['suggestions'] as List<dynamic>?;
    if (suggestions == null || suggestions.isEmpty) {
      return _fallbackSmartSuggestions(isHindi: isHindiLanguage(lang));
    }
    return suggestions
        .map((item) => AiSmartSuggestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<AiTimelineEntry>> fetchMealTimeline({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.65);
    final timeline = response?['timeline'] as List<dynamic>?;
    if (timeline == null || timeline.isEmpty) {
      return _fallbackTimeline(isHindi: isHindiLanguage(lang));
    }
    return timeline.map((item) => AiTimelineEntry.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<AiInsight>> fetchHealthInsights({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.7);
    final insights = response?['insights'] as List<dynamic>?;
    if (insights == null || insights.isEmpty) {
      return _fallbackInsights(isHindi: isHindiLanguage(lang));
    }
    return insights.map((item) => AiInsight.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<AiMacroBreakdown?> fetchMacroBreakdown({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.55);
    if (response == null) {
      return _fallbackMacroBreakdown(isHindi: isHindiLanguage(lang));
    }
    return AiMacroBreakdown.fromJson(response);
  }

  static Future<List<AiCuratedMealNote>> fetchCuratedMealNotes({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.7);
    final meals = response?['meals'] as List<dynamic>?;
    if (meals == null || meals.isEmpty) {
      return _fallbackCuratedNotes(isHindi: isHindiLanguage(lang));
    }
    return meals.map((item) => AiCuratedMealNote.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<MealStudioIdea>> fetchMealStudioIdeas({
    required String mealType,
    User? user,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: $payload
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.9);
    final ideas = response?['ideas'] as List<dynamic>?;
    if (ideas == null || ideas.isEmpty) {
      return _fallbackMealIdeas(mealType, isHindi: isHindiLanguage(lang));
    }
    return ideas.map((item) => MealStudioIdea.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<List<AiWeekPlanDay>> fetchWeeklyPlan({
    User? user,
    MealPlan? mealPlan,
    String? language,
  }) async {
    final lang = language ?? user?.language;
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
Context: ${_buildContext(user, mealPlan)}
$_indiaCultureGuardrails
Language: ${_languageDirective(lang)}''';

    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.6);
    final week = response?['week'] as List<dynamic>?;
    if (week == null || week.isEmpty) {
      return _fallbackWeeklyPlan(isHindi: isHindiLanguage(lang));
    }
    return week.map((item) => AiWeekPlanDay.fromJson(item as Map<String, dynamic>)).toList();
  }

  static Future<String> getCoachResponse({
    required String userMessage,
    required List<Map<String, String>> history,
    User? user,
    String? language,
  }) async {
    final lang = language ?? user?.language;
    final conversation = <Map<String, String>>[
      {
        'role': 'system',
        'content':
            'Act as a compassionate Indian nutrition coach. Reply conversationally (max 120 words), weave in familiar staples like dal, roti, curd, millets, and yoga or pranayama cues, reference prior context, finish with a concrete action that feels doable for a middle-class family. ${_languageDirective(lang)}',
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

    if (reply != null) return reply;
    return isHindiLanguage(lang)
      ? 'मैं अभी सोच रहा हूँ, कृपया दोबारा प्रयास करें।'
      : 'I am still thinking, try again in a moment.';
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

  static List<AiSmartSuggestion> _fallbackSmartSuggestions({required bool isHindi}) {
    if (isHindi) {
      return [
        AiSmartSuggestion(
          title: 'नींबू पानी से शुरुआत करें',
          subtitle: 'सुबह की चाय से पहले गुनगुना पानी + नींबू + चुटकी भर काला नमक पेट को हल्का रखता है।',
          category: 'mindfulness',
          tone: 'gentle',
          refreshHint: 'हाइड्रेशन पहले पूरा करें ताकि दिन भर पानी पीना आसान लगे।',
        ),
        AiSmartSuggestion(
          title: 'दाल-चावल थाली को अपग्रेड करें',
          subtitle: 'चावल से पहले छोटी कटोरी स्प्राउट्स या पनीर भुर्जी खाएँ ताकि ऊर्जा स्थिर रहे।',
          category: 'chef',
          tone: 'bold',
          refreshHint: 'भोजन के बाद आने वाली सुस्ती को रोकेगा।',
        ),
        AiSmartSuggestion(
          title: 'मिनी सूर्य नमस्कार ब्रेक',
          subtitle: 'हर 90 मिनट में 2 राउंड करने से घर/ऑफिस बैठने की जकड़न कम होती है।',
          category: 'insight',
          tone: 'celebratory',
          refreshHint: 'जिम की ज़रूरत बिना ही मोबिलिटी बनी रहती है।',
        ),
      ];
    }

    return [
      AiSmartSuggestion(
        title: 'Start with nimbu paani',
        subtitle: 'Warm water + lemon + pinch of kala namak before chai keeps digestion light.',
        category: 'mindfulness',
        tone: 'gentle',
        refreshHint: 'Sets up hydration before the morning tea habit kicks in.',
      ),
      AiSmartSuggestion(
        title: 'Upgrade dal-chawal plate',
        subtitle: 'Add a katori of sprouts or paneer bhurji before rice for steadier energy.',
        category: 'chef',
        tone: 'bold',
        refreshHint: 'Balances the post-lunch slump common with heavy carbs.',
      ),
      AiSmartSuggestion(
        title: 'Mini surya namaskar breaks',
        subtitle: '2 rounds every 90 minutes keeps posture open during WFH marathons.',
        category: 'insight',
        tone: 'celebratory',
        refreshHint: 'Yoga flow doubles as mobility without needing gym space.',
      ),
    ];
  }

  static List<AiTimelineEntry> _fallbackTimeline({required bool isHindi}) {
    if (isHindi) {
      return [
        AiTimelineEntry(
          window: '06:00 - 07:30',
          label: 'सूर्य नमस्कार + घूँट',
          focus: 'हाइड्रेशन और हल्का योग',
          action: 'नींबू पानी के बाद खिड़की के पास 4 राउंड सूर्य नमस्कार।',
        ),
        AiTimelineEntry(
          window: '08:00 - 10:00',
          label: 'देसी नाश्ता फ्यूल',
          focus: 'प्रोटीन-फर्स्ट प्लेट',
          action: 'पोहे/उपमा/इडली के साथ दही या स्प्राउट्स लें फिर पहली चाय।',
        ),
        AiTimelineEntry(
          window: '13:00 - 14:30',
          label: 'दाल-सब्ज़ी लंच वॉक',
          focus: 'फाइबर + टहलना',
          action: 'आधी थाली सलाद, दाल, सब्ज़ी और बाद में 7 मिनट गलियारा वॉक।',
        ),
        AiTimelineEntry(
          window: '16:30 - 18:00',
          label: 'मसाला चाय गार्डरेल',
          focus: 'स्मार्ट स्नैक',
          action: 'चाय के साथ भीगे बादाम/चना लें और दो मंज़िल सीढ़ियाँ चढ़ें।',
        ),
        AiTimelineEntry(
          window: '20:00 - 21:30',
          label: 'हल्का डिनर + प्राणायाम',
          focus: 'आसान पाचन',
          action: 'मिलेट खिचड़ी या सूप, फिर 4-7-8 ब्रीदिंग करके सोएँ।',
        ),
      ];
    }

    return [
      AiTimelineEntry(
        window: '06:00 - 07:30',
        label: 'Sun salutations & sip',
        focus: 'Hydration + gentle yoga',
        action: 'Nimbu paani followed by 4 rounds of surya namaskar near a window.',
      ),
      AiTimelineEntry(
        window: '08:00 - 10:00',
        label: 'Desi breakfast fuel',
        focus: 'Protein-first plates',
        action: 'Pair poha/upma/idli with curd or sprouts before the first chai.',
      ),
      AiTimelineEntry(
        window: '13:00 - 14:30',
        label: 'Dal-sabzi lunch walk',
        focus: 'Fiber + stroll',
        action: 'Half plate salad, dal, sabzi, then a 7-min corridor walk.',
      ),
      AiTimelineEntry(
        window: '16:30 - 18:00',
        label: 'Masala chai guardrail',
        focus: 'Smart snacking',
        action: 'Enjoy chai with 8 soaked almonds or chana, then climb two flights of stairs.',
      ),
      AiTimelineEntry(
        window: '20:00 - 21:30',
        label: 'Light dinner + pranayama',
        focus: 'Easy digestion',
        action: 'Millet khichdi or veg soup, then 4-7-8 breathing before lights out.',
      ),
    ];
  }

  static List<AiInsight> _fallbackInsights({required bool isHindi}) {
    if (isHindi) {
      return [
        AiInsight(
          title: 'स्टील बोतल दो बार भरें',
          summary: 'कल सिर्फ 1.2 लीटर पानी लॉग हुआ। लंच से पहले दो 600ml रीफिल अंतर पूरा करेंगे।',
          action: 'डेस्क पर स्टील/तांबे की बोतल रखें और हर 30 मिनट में 4 घूँट लें।',
          category: 'hydration',
        ),
        AiInsight(
          title: 'पनीर + दाल कॉम्बो सफल',
          summary: 'स्प्राउट्स और पनीर की वजह से नाश्ता व लंच में 50g से अधिक प्रोटीन मिल चुका है।',
          action: 'डिनर में एक कटोरी दाल तड़का या दही ज़रूर जोड़ें।',
          category: 'biomarker',
        ),
        AiInsight(
          title: 'माइंडसेट मिनी-रीसेट',
          summary: 'रात 10 बजे के बाद भी हार्ट रेट ऊँचा रहा, मतलब देर तक स्क्रीन टाइम चल रहा है।',
          action: 'ब्रश के बाद 4-7-8 प्राणायाम करें ताकि दिमाग को आराम का सिग्नल मिले।',
          category: 'mindset',
        ),
      ];
    }

    return [
      AiInsight(
        title: 'Refill the steel bottle twice',
        summary: 'Only 1.2L logged yesterday. Two 600ml refills before lunch closes the gap.',
        action: 'Keep a copper/steel bottle on your desk and sip 4 gulps every 30 minutes.',
        category: 'hydration',
      ),
      AiInsight(
        title: 'Paneer + dal combo is winning',
        summary: 'Breakfast and lunch already crossed 50g protein thanks to sprouts and paneer.',
        action: 'Add a katori of dal tadka or curd with dinner to keep muscles fed.',
        category: 'biomarker',
      ),
      AiInsight(
        title: 'Mindset mini-reset',
        summary: 'Heart rate stayed high past 10 PM, hinting at late-night scrolling.',
        action: 'Practice 4-7-8 pranayama right after brushing to signal your brain to switch off.',
        category: 'mindset',
      ),
    ];
  }

  static AiMacroBreakdown _fallbackMacroBreakdown({required bool isHindi}) {
    if (isHindi) {
      return AiMacroBreakdown(
        headline: 'कैलोरी लक्ष्य से थोड़ा कम',
        calorieSummary: 'लगभग 180 kcal कम रह गए, अक्सर तब होता है जब डिनर सिर्फ सब्ज़ी + रोटी हो।',
        macros: [
          AiMacroStat(label: 'Protein', grams: 92, insight: '+20g की गुंजाइश — डिनर में दही, पनीर या दाल जोड़ें'),
          AiMacroStat(label: 'Carbs', grams: 165, insight: 'रोटी + मिलेट से ठीक चल रहा है, आधी थाली सब्ज़ी रखें'),
          AiMacroStat(label: 'Fat', grams: 58, insight: 'रात के तले स्नैक्स कम रखें ताकि 70g से नीचे रहें'),
        ],
        callToAction: 'डिनर में दाल, दही चावल या स्प्राउट्स चाट जोड़ें ताकि गैप भर जाए।',
      );
    }

    return AiMacroBreakdown(
      headline: 'Calories slightly below target',
      calorieSummary: 'About 180 kcal under your sweet spot — common when dinner is just sabzi + roti.',
      macros: [
        AiMacroStat(label: 'Protein', grams: 92, insight: 'Room for +20g — add curd, paneer, or dal at dinner'),
        AiMacroStat(label: 'Carbs', grams: 165, insight: 'On track with rotis + millets, keep veggies half the plate'),
        AiMacroStat(label: 'Fat', grams: 58, insight: 'Stay under 70g by limiting late-night fried snacks'),
      ],
      callToAction: 'Add a katori of dal, curd rice, or sprouts chaat at dinner to close the gap.',
    );
  }

  static List<AiCuratedMealNote> _fallbackCuratedNotes({required bool isHindi}) {
    if (isHindi) {
      return [
        AiCuratedMealNote(
          mealType: 'breakfast',
          highlight: 'सब्ज़ियों वाला पोहा + मूँगफली',
          reason: 'करी पत्ता, मूँगफली और स्प्राउट्स से क्रंच मिलता है और कार्ब्स स्थिर रहते हैं।',
          calories: 380,
          macros: const {'protein': 16.0, 'carbs': 52.0, 'fat': 11.0},
          tags: const ['कम_GI', 'घरेलू_स्वाद'],
        ),
        AiCuratedMealNote(
          mealType: 'lunch',
          highlight: 'कंफर्ट दाल-चावल + सब्ज़ी',
          reason: 'अतिरिक्त हरी सब्ज़ी के साथ हल्का yet भरपेट रहता है।',
          calories: 520,
          macros: const {'protein': 24.0, 'carbs': 68.0, 'fat': 14.0},
          tags: const ['घर_का_खाना', 'संतुलित_थाली'],
        ),
        AiCuratedMealNote(
          mealType: 'dinner',
          highlight: 'पालक पनीर + ज्वार रोटी',
          reason: 'आयरन से भरपूर पालक और स्लो कार्ब्स रात के खाने को हल्का रखते हैं।',
          calories: 450,
          macros: const {'protein': 30.0, 'carbs': 32.0, 'fat': 18.0},
          tags: const ['उच्च_प्रोटीन', 'मिलेट_स्वैप'],
        ),
      ];
    }

    return [
      AiCuratedMealNote(
        mealType: 'breakfast',
        highlight: 'Veggie poha with peanuts',
        reason: 'Uses curry leaves, peanuts, and sprouts for crunch plus steady carbs.',
        calories: 380,
        macros: const {'protein': 16.0, 'carbs': 52.0, 'fat': 11.0},
        tags: const ['low_gi', 'familiar_flavors'],
      ),
      AiCuratedMealNote(
        mealType: 'lunch',
        highlight: 'Comfort dal-chawal + sabzi',
        reason: 'Classic combo with extra leafy sabzi keeps it light yet satisfying.',
        calories: 520,
        macros: const {'protein': 24.0, 'carbs': 68.0, 'fat': 14.0},
        tags: const ['home_style', 'balanced_plate'],
      ),
      AiCuratedMealNote(
        mealType: 'dinner',
        highlight: 'Palak paneer + jowar roti',
        reason: 'Iron-rich spinach with slow carbs keeps late dinners easy.',
        calories: 450,
        macros: const {'protein': 30.0, 'carbs': 32.0, 'fat': 18.0},
        tags: const ['high_protein', 'millet_swap'],
      ),
    ];
  }

  static List<MealStudioIdea> _fallbackMealIdeas(String mealType, {required bool isHindi}) {
    final label = mealType[0].toUpperCase() + mealType.substring(1);
    if (isHindi) {
      return [
        MealStudioIdea(
          name: '$label पनीर भुर्जी मिलेट रैप',
          description: 'मसालेदार पनीर भुर्जी, प्याज़ और पुदीना चटनी को ज्वार रोटी में रोल करें।',
          calories: 460,
          macros: const {'protein': 30.0, 'carbs': 48.0, 'fat': 16.0},
          tags: const ['उच्च_प्रोटीन', 'मिलेट_स्वैप'],
          steps: const ['पनीर को मसालों के साथ भूनें', 'मिलेट रोटी गर्म करें', 'चटनी और सलाद के साथ रोल करें'],
        ),
        MealStudioIdea(
          name: '$label मसाला छाछ बाउल',
          description: 'हंग कर्ड + छाछ बेस पर भुना चना, खीरा और करी पत्ता तड़का।',
          calories: 320,
          macros: const {'protein': 22.0, 'carbs': 30.0, 'fat': 12.0},
          tags: const ['आंत_स्वास्थ्य', 'ग्रीष्म_अनुकूल'],
          steps: const ['दही को मसालों संग फेंटें', 'टॉपिंग डालें', 'राई-जीरा का तड़का लगाएँ'],
        ),
        MealStudioIdea(
          name: '$label सब्ज़ी खिचड़ी + कचुम्बर',
          description: 'मूँग दाल + मिलेट खिचड़ी पर घी का तड़का और कुरकुरा ककड़ी सलाद।',
          calories: 500,
          macros: const {'protein': 24.0, 'carbs': 62.0, 'fat': 16.0},
          tags: const ['कम्फर्ट_फूड', 'वन_पॉट'],
          steps: const ['दाल व मिलेट को सब्ज़ियों संग कुकर में पकाएँ', 'जल्दी सलाद बनाएं', 'ऊपर से घी डालें'],
        ),
      ];
    }

    return [
      MealStudioIdea(
        name: '$label paneer bhurji millet wrap',
        description: 'Spiced paneer bhurji, onions, and mint chutney rolled in a jowar roti.',
        calories: 460,
        macros: const {'protein': 30.0, 'carbs': 48.0, 'fat': 16.0},
        tags: const ['high_protein', 'millet_swap'],
        steps: const ['Crumble and saute paneer with masala', 'Warm millet rotis', 'Roll with chutney + veggies'],
      ),
      MealStudioIdea(
        name: '$label masala buttermilk bowl',
        description: 'Hung curd + buttermilk base topped with roasted chana, cucumber, and curry leaves tadka.',
        calories: 320,
        macros: const {'protein': 22.0, 'carbs': 30.0, 'fat': 12.0},
        tags: const ['gut_health', 'summer_ready'],
        steps: const ['Blend curd with spices', 'Add toppings', 'Finish with mustard seed tempering'],
      ),
      MealStudioIdea(
        name: '$label veggie khichdi + kachumber',
        description: 'Moong dal + millet khichdi with ghee tempering and crunchy cucumber salad.',
        calories: 500,
        macros: const {'protein': 24.0, 'carbs': 62.0, 'fat': 16.0},
        tags: const ['comfort_food', 'one_pot'],
        steps: const ['Pressure cook dal + millets with veggies', 'Prepare quick salad', 'Serve with ghee drizzle'],
      ),
    ];
  }

  static List<AiWeekPlanDay> _fallbackWeeklyPlan({required bool isHindi}) {
    if (isHindi) {
      return [
        AiWeekPlanDay(
          day: 'Mon',
          headline: 'आयुर्वेदिक रीसेट',
          focus: 'गर्म पानी, योग और हल्की खिचड़ी से हफ्ता शुरू करें।',
          mealTheme: 'मूँग दाल खिचड़ी',
          anchors: const [
            'AM: नींबू पानी + 5 राउंड सूर्य नमस्कार',
            'Mid: दाल-चावल से पहले आधी थाली सलाद',
            'PM: 10 मिनट अनुलोम-विलोम',
          ],
        ),
        AiWeekPlanDay(
          day: 'Tue',
          headline: 'मिलेट एक्सपेरिमेंट',
          focus: 'एनर्जी steady रखने के लिए डिनर में ज्वार/बाजरा लें।',
          mealTheme: 'मिलेट रोटी',
          anchors: const [
            'AM: स्प्राउट्स + दही नाश्ते के साथ',
            'Mid: लंच के बाद 8 मिनट सीढ़ियाँ',
            'PM: 8:30 PM से पहले बाजरा रोटी + पालक पनीर',
          ],
        ),
        AiWeekPlanDay(
          day: 'Wed',
          headline: 'ग्लूकोज़ गार्डरेल',
          focus: 'फाइबर-फर्स्ट बाइट और छोटी टेरेस वॉक रखें।',
          mealTheme: 'सब्ज़ी प्रधान थाली',
          anchors: const [
            'AM: चाय से पहले 1 चम्मच अलसी चटनी',
            'Mid: लंच के बाद 10 मिनट टेरेस वॉक',
            'PM: डेज़र्ट की जगह जीरा-अजवाइन काढ़ा',
          ],
        ),
        AiWeekPlanDay(
          day: 'Thu',
          headline: 'नर्वस सिस्टम शांति',
          focus: 'रात के खाने को सूप/स्टू रखें और यिन स्ट्रेच करें।',
          mealTheme: 'सब्ज़ी स्टू + डोसा',
          anchors: const [
            'AM: मीटिंग से पहले 5 मिनट बॉडी स्कैन',
            'Mid: घर का बना अचार गट हेल्थ के लिए',
            'PM: लेग्स-अप-द-वाल + कैमोमाइल चाय',
          ],
        ),
        AiWeekPlanDay(
          day: 'Fri',
          headline: 'स्ट्रेंथ प्राइमर',
          focus: 'शाम के वर्कआउट से पहले चावल + दही और भरपूर पानी लें।',
          mealTheme: 'वर्कआउट प्रीप दही चावल',
          anchors: const [
            'AM: मोबिलिटी + 500ml नमक वाला नारियल पानी',
            'Mid: जिम से पहले शकरकंद चाट',
            'PM: वर्कआउट के 30 मिनट भीतर लस्सी + केला',
          ],
        ),
        AiWeekPlanDay(
          day: 'Sat',
          headline: 'रिकवरी + मस्ती',
          focus: 'परिवार का खाना खाएँ लेकिन हाइड्रेशन को एंकर रखें।',
          mealTheme: 'घर का ब्रंच',
          anchors: const [
            'AM: बाहर जाने से पहले नारियल पानी',
            'Mid: पाव भाजी शेयर करें लेकिन सलाद/पनीर जोड़ें',
            'PM: फोम रोलिंग या योग निद्रा',
          ],
        ),
        AiWeekPlanDay(
          day: 'Sun',
          headline: 'होम प्रेप डे',
          focus: 'दाल बैच-कुक करें, सब्ज़ियाँ काटें, नींद की लय सेट करें।',
          mealTheme: 'मील-प्रेप स्टेपल्स',
          anchors: const [
            'AM: ग्रैटिट्यूड जर्नल + बालकनी सनलाइट',
            'Mid: हफ्ते के लिए दाल प्रेशर कुकर में पकाएँ',
            'PM: टिफिन प्लान + 10 बजे लाइट्स ऑफ',
          ],
        ),
      ];
    }

    return [
      AiWeekPlanDay(
        day: 'Mon',
        headline: 'Ayurvedic reset',
        focus: 'Start the week with warm water, yoga, and lighter khichdi meals.',
        mealTheme: 'Moong dal khichdi',
        anchors: const [
          'AM: Nimbu paani + 5 rounds surya namaskar',
          'Mid: Half plate salad before dal-rice',
          'PM: 10 mins alternate nostril breathing',
        ],
      ),
      AiWeekPlanDay(
        day: 'Tue',
        headline: 'Millet experiment',
        focus: 'Swap wheat with jowar/bajra for dinner to keep energy steady.',
        mealTheme: 'Millet rotis',
        anchors: const [
          'AM: Sprouts + curd with breakfast',
          'Mid: 8-min stair climb after lunch',
          'PM: Bajra roti + palak paneer before 8:30 PM',
        ],
      ),
      AiWeekPlanDay(
        day: 'Wed',
        headline: 'Glucose guardrail',
        focus: 'Use fiber-first bites and quick terrace walks.',
        mealTheme: 'Sabzi-heavy thali',
        anchors: const [
          'AM: 1 tbsp flaxseed chutney before chai',
          'Mid: 10-min terrace walk post lunch',
          'PM: Jeera-ajwain kadha instead of dessert',
        ],
      ),
      AiWeekPlanDay(
        day: 'Thu',
        headline: 'Nervous-system calm',
        focus: 'Keep dinners broth-based and stretch with yin poses.',
        mealTheme: 'Vegetable stew + dosa',
        anchors: const [
          'AM: 5-min body scan before meetings',
          'Mid: Add homemade pickle for gut health',
          'PM: Legs-up-the-wall + chamomile tea',
        ],
      ),
      AiWeekPlanDay(
        day: 'Fri',
        headline: 'Strength primer',
        focus: 'Fuel evening workouts with rice + curd and plenty of water.',
        mealTheme: 'Pre-lift curd rice',
        anchors: const [
          'AM: Mobility + 500ml salted coconut water',
          'Mid: Sweet potato chaat before gym',
          'PM: Lassi + banana within 30 mins post workout',
        ],
      ),
      AiWeekPlanDay(
        day: 'Sat',
        headline: 'Recovery + play',
        focus: 'Enjoy family foods but anchor with hydration.',
        mealTheme: 'Home-style brunch',
        anchors: const [
          'AM: Tender coconut water before stepping out',
          'Mid: Share pav bhaji with extra salad + paneer topping',
          'PM: Foam rolling or gentle yoga nidra session',
        ],
      ),
      AiWeekPlanDay(
        day: 'Sun',
        headline: 'House prep day',
        focus: 'Batch-cook dals, cut veggies, and reset sleep rhythm.',
        mealTheme: 'Meal prep staples',
        anchors: const [
          'AM: Gratitude journaling + balcony sunlight',
          'Mid: Pressure cook dal + roast veggies for the week',
          'PM: Plan tiffin menu + lights out by 10 PM',
        ],
      ),
    ];
  }
}
