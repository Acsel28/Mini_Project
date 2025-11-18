import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';

// Chatbot response model
class ChatbotResponse {
  final int questionId;
  final String questionText;
  final String selectedOption;
  final String answer;
  final DateTime createdAt;

  ChatbotResponse({
    required this.questionId,
    required this.questionText,
    required this.selectedOption,
    required this.answer,
    required this.createdAt,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    return ChatbotResponse(
      questionId: json['question_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      selectedOption: json['selected_option'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Chatbot responses notifier
class ChatbotResponsesNotifier extends StateNotifier<AsyncValue<List<ChatbotResponse>>> {
  ChatbotResponsesNotifier() : super(const AsyncValue.data([]));

  Future<void> fetchResponses() async {
    state = const AsyncValue.loading();
    try {
      final rawResponses = await AnalyticsService.getChatbotResponses();
      if (rawResponses != null) {
        final mapped = rawResponses.map((r) => ChatbotResponse.fromJson(r as Map<String, dynamic>)).toList();
        state = AsyncValue.data(mapped);
      } else {
        state = const AsyncValue.data([]);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Provider
final chatbotResponsesProvider =
    StateNotifierProvider<ChatbotResponsesNotifier, AsyncValue<List<ChatbotResponse>>>((ref) {
  return ChatbotResponsesNotifier();
});
