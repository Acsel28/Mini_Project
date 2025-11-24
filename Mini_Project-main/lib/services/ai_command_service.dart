import 'dart:developer' as developer;

import '../models/voice_command_result.dart';
import 'groq_service.dart';

class AiCommandService {
  static Future<VoiceCommandResult?> interpret(String utterance) async {
    final prompt = _buildPrompt(utterance);
    final response = await GroqService.structuredJson(prompt: prompt, temperature: 0.3);
    if (response == null) {
      developer.log('Groq command response was null');
      return null;
    }

    final intent = response['intent']?.toString();
    if (intent == null || intent.isEmpty) return null;

    return VoiceCommandResult(
      intent: intent,
      entities: Map<String, dynamic>.from(response['entities'] ?? <String, dynamic>{}),
      utterance: response['utterance']?.toString(),
      confidence: (response['confidence'] as num?)?.toDouble(),
    );
  }

  static String _buildPrompt(String utterance) {
    return '''You are the intent router for a voice-driven nutrition coach. Classify the utterance and emit STRICT JSON (no markdown fences, no prose).

JSON shape:
{
  "intent": "open_screen" | "summarize_meal_plan" | "generate_meal_plan" | "add_meal_log" | "log_water" | "log_sleep" | "search_condition" | "coach_tip" | "help",
  "entities": {
    "screen"?: string (home|insights|progress|profile|coach|search|analytics|ingredients),
    "meal_type"?: string (breakfast|lunch|dinner),
    "water_ml"?: number (integer milliliters),
    "sleep_hours"?: number,
    "condition"?: string,
    "topic"?: string
  },
  "confidence": number between 0 and 1,
  "utterance": cleaned user command
}

Guidance:
- Choose "open_screen" for navigation verbs (open, go to, show) and map synonyms like "analytics", "coach chat" accordingly.
- "summarize_meal_plan" when user asks about meals ("what's for breakfast", "tell me lunch"). Include meal_type if implied; default breakfast.
- "generate_meal_plan" for regenerate/create/update meal plan requests.
- "add_meal_log" when user says add/log/save a meal or wants the meal logging screen. No extra entities needed.
- "log_water" when user logs drinks; infer 250ml if missing amount.
- "log_sleep" for sleep tracking; infer 7 hours if unspecified.
- "search_condition" for health issue lookups (symptoms, diseases, conditions keyword).
- "coach_tip" for requests to the AI coach, mindset tips, reminders; include topic if stated.
- Otherwise set intent to "help".

Always populate entities only when relevant. Respond with valid JSON only.

User: "$utterance"''';
  }
}
