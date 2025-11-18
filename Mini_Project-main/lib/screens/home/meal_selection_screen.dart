import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/analytics_service.dart';

// State provider for selected meal type
final selectedMealTypeProvider = StateProvider<String>((ref) => 'breakfast');

// State provider for meal suggestions
final mealSuggestionsProvider = FutureProvider.family<Map<String, dynamic>?, String>((ref, mealType) async {
  return await AnalyticsService.getMealSuggestions(mealType: mealType);
});

class MealSelectionScreen extends ConsumerWidget {
  const MealSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMealType = ref.watch(selectedMealTypeProvider);
    final mealsAsync = ref.watch(mealSuggestionsProvider(selectedMealType));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Meal'),
        backgroundColor: const Color(0xFF4DB8C4),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Meal type selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'breakfast',
                  label: Text('Breakfast'),
                  icon: Icon(Icons.wb_sunny),
                ),
                ButtonSegment(
                  value: 'lunch',
                  label: Text('Lunch'),
                  icon: Icon(Icons.lunch_dining),
                ),
                ButtonSegment(
                  value: 'dinner',
                  label: Text('Dinner'),
                  icon: Icon(Icons.dinner_dining),
                ),
              ],
              selected: {selectedMealType},
              onSelectionChanged: (Set<String> newSelection) {
                ref.read(selectedMealTypeProvider.notifier).state = newSelection.first;
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFF4DB8C4);
                  }
                  return Colors.grey[200] ?? Colors.grey;
                }),
              ),
            ),
          ),
          // Meal suggestions list
          Expanded(
            child: mealsAsync.when(
              data: (data) {
                if (data == null || data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No meals available',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Extract meals from response
                final meals = data['meals'] as List<dynamic>? ?? [];
                
                if (meals.isEmpty) {
                  return Center(
                    child: Text('No ${selectedMealType} suggestions found'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index] as Map<String, dynamic>;
                    return _buildMealCard(context, meal);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepOrange,
                ),
              ),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading meals',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, Map<String, dynamic> meal) {
    final name = meal['title'] ?? meal['name'] ?? 'Unknown Meal';
    final calories = meal['calories'] ?? 0;
    
    // Handle both nested macros object and flat properties
    final macros = meal['macros'] as Map<String, dynamic>?;
    final protein = (macros?['protein'] ?? meal['protein'] ?? 0).toInt();
    final carbs = (macros?['carbs'] ?? meal['carbs'] ?? 0).toInt();
    final fat = (macros?['fat'] ?? meal['fat'] ?? 0).toInt();
    
    final description = meal['description'] ?? '';
    final tags = (meal['tags'] as List<dynamic>?)?.cast<String>() ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meal name and calories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F7FA),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$calories cal',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4DB8C4),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            if (description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Macros breakdown
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroLabel('Protein', protein, 'g'),
                _buildMacroLabel('Carbs', carbs, 'g'),
                _buildMacroLabel('Fat', fat, 'g'),
              ],
            ),
            // Tags
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.green[100],
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  );
                }).toList(),
              ),
            ],
            // Select button
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added $name to your meal plan'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4DB8C4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Select Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroLabel(String label, dynamic value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value$unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4DB8C4),
          ),
        ),
      ],
    );
  }
}
