import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';

// Hardcoded questions with options
final List<Map<String, dynamic>> hardcodedQuestions = [
  {
    'id': 1,
    'question': 'What dietary preference do you follow?',
    'type': 'single_select',
    'options': ['Vegetarian', 'Non-Vegetarian', 'Vegan', 'Keto', 'Paleo'],
    'answers': {
      'Vegetarian': 'Vegetarian meals are rich in vegetables, legumes, and dairy. They provide excellent protein through beans and lentils.',
      'Non-Vegetarian': 'Non-vegetarian diets include lean meats, fish, and poultry. Great source of complete proteins and iron.',
      'Vegan': 'Vegan meals use only plant-based ingredients. Combine grains with legumes for complete proteins.',
      'Keto': 'Ketogenic diet focuses on high fat, moderate protein, low carbs. Good for weight loss and mental clarity.',
      'Paleo': 'Paleo diet emphasizes whole foods like meat, fish, vegetables, and fruits. Avoids processed foods and grains.'
    }
  },
  {
    'id': 2,
    'question': 'What is your fitness goal?',
    'type': 'single_select',
    'options': ['Weight Loss', 'Muscle Gain', 'Maintenance', 'Endurance', 'Overall Health'],
    'answers': {
      'Weight Loss': 'Focus on calorie deficit with 40% protein, 30% carbs, 30% fat. Include more fiber and water.',
      'Muscle Gain': 'Consume high protein (1g per lb of body weight), adequate carbs for energy, and strength training.',
      'Maintenance': 'Balanced macros: 40% protein, 35% carbs, 25% fat. Regular exercise and consistent eating habits.',
      'Endurance': 'Carb-loading before events, high carbs (50%), moderate protein, good hydration.',
      'Overall Health': 'Balanced nutrition with whole foods, regular exercise, adequate sleep, and stress management.'
    }
  },
  {
    'id': 3,
    'question': 'How many meals per day do you prefer?',
    'type': 'single_select',
    'options': ['3 Meals', '4-5 Meals', '6+ Meals', 'Intermittent Fasting'],
    'answers': {
      '3 Meals': 'Traditional 3-meal approach: Breakfast, Lunch, Dinner. Best for consistent energy throughout the day.',
      '4-5 Meals': 'Frequent smaller meals: Helps maintain stable blood sugar and prevents overeating.',
      '6+ Meals': 'Multiple meals and snacks: Good for muscle building and keeping metabolism active.',
      'Intermittent Fasting': 'Eating within specific time windows. May improve metabolism and autophagy.'
    }
  },
  {
    'id': 4,
    'question': 'What health condition are you managing?',
    'type': 'single_select',
    'options': ['Diabetes', 'Hypertension', 'Heart Disease', 'PCOD/PCOS', 'No Specific Condition'],
    'answers': {
      'Diabetes': 'Focus on low glycemic index foods, control carb portions, include fiber, monitor blood sugar regularly.',
      'Hypertension': 'Reduce sodium intake, increase potassium-rich foods, limit processed foods, stay hydrated.',
      'Heart Disease': 'Choose lean proteins, healthy fats (omega-3), whole grains, reduce saturated fats.',
      'PCOD/PCOS': 'Anti-inflammatory foods, protein-rich meals, limit refined carbs, regular exercise.',
      'No Specific Condition': 'Follow balanced nutrition with variety. Include all food groups in moderation.'
    }
  },
  {
    'id': 5,
    'question': 'What is your activity level?',
    'type': 'single_select',
    'options': ['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active', 'Extremely Active'],
    'answers': {
      'Sedentary': 'Low calorie needs. Focus on whole foods, maintain movement throughout the day.',
      'Lightly Active': 'Light exercise 1-3 days/week. Eat nutritious meals with moderate portions.',
      'Moderately Active': 'Exercise 3-5 days/week. Increase carbs and protein for workout recovery.',
      'Very Active': 'Exercise 6-7 days/week. High calorie needs, focus on nutrient density.',
      'Extremely Active': 'Intense training daily. Maximum protein, carbs, and calories for recovery.'
    }
  }
];

class CoachChatScreen extends ConsumerStatefulWidget {
  const CoachChatScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CoachChatScreen> createState() => _CoachChatScreenState();
}

class _CoachChatScreenState extends ConsumerState<CoachChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Start with first question
    _showQuestion();
  }

  void _showQuestion() {
    if (_currentQuestionIndex < hardcodedQuestions.length) {
      final question = hardcodedQuestions[_currentQuestionIndex];
      setState(() {
        _messages.add({
          'role': 'coach',
          'type': 'question',
          'question': question['question'],
          'options': question['options'],
          'questionId': question['id']
        });
      });
    } else {
      // All questions answered
      setState(() {
        _messages.add({
          'role': 'coach',
          'type': 'text',
          'text': 'Great! I\'ve gathered all the information. Your personalized health plan is ready. Check your Home screen for your meal plan and health recommendations!'
        });
      });
    }
  }

  Future<void> _selectOption(String selectedOption, int questionId) async {
    final question = hardcodedQuestions.firstWhere((q) => q['id'] == questionId);
    final answer = question['answers'][selectedOption] ?? 'No answer available';

    setState(() {
      _isLoading = true;
      // Add user selection
      _messages.add({
        'role': 'user',
        'type': 'text',
        'text': selectedOption
      });
      // Add coach answer
      _messages.add({
        'role': 'coach',
        'type': 'text',
        'text': answer
      });
    });

    // Save response to backend/database
    try {
      final token = await AuthService.getAccessToken();
      if (token != null) {
        await AnalyticsService.saveCoachResponse(
          questionId: questionId,
          selectedOption: selectedOption,
          answer: answer,
          token: token,
        );
        print('[Coach] Response saved: Q$questionId -> $selectedOption');
      }
    } catch (e) {
      print('[Coach] Error saving response: $e');
    }

    // Move to next question
    setState(() {
      _currentQuestionIndex++;
      _isLoading = false;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    _showQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Coach'),
        backgroundColor: Color(0xFF4DB8C4),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';

                if (msg['type'] == 'question') {
                  return _buildQuestionWidget(msg);
                } else {
                  return _buildMessageWidget(msg, isUser);
                }
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageWidget(Map<String, dynamic> msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? Color(0xFF4DB8C4).withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(
          msg['text'] ?? '',
          style: TextStyle(
            fontSize: 14,
            color: isUser ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionWidget(Map<String, dynamic> msg) {
    final options = msg['options'] as List<String>;
    final questionId = msg['questionId'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              msg['question'] ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: options.map((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _selectOption(option, questionId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4DB8C4),
                    disabledBackgroundColor: Colors.grey[300],
                    minimumSize: Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
