import 'package:flutter/material.dart';
import '../../models/meal_model.dart';
import '../../services/voice_assistant_service.dart';
import '../../services/tts_service.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Meal meal;
  const RecipeDetailScreen({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    final steps = meal.instructions;
    // provide the steps to the voice assistant so "next step" works
    VoiceAssistantService.setLastSteps(steps);

    return Scaffold(
      appBar: AppBar(title: Text(meal.name)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(meal.ingredients.join(', ')),
            const SizedBox(height: 16),
            Text('Steps', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: steps.length,
                itemBuilder: (context, idx) {
                  return ListTile(
                    leading: CircleAvatar(child: Text('${idx + 1}')),
                    title: Text(steps[idx]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                TTSService.speak('Starting recipe steps: ${steps.first}');
                VoiceAssistantService.setLastSteps(steps);
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start guided cooking'),
            )
          ],
        ),
      ),
    );
  }
}
