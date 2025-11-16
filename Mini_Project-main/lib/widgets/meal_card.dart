import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/meal_model.dart';
import '../services/tts_service.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final String mealType;
  final Color color;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.meal,
    required this.mealType,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: AppStyles.cardDecoration,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMealIcon(mealType),
                      color: color,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealType,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        if (meal.cookTime.isNotEmpty)
                          Text(
                            meal.cookTime,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                      ],
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: () => _speakMealInfo(),
                    color: AppColors.textSecondary,
                    tooltip: 'Read aloud',
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cuisine and difficulty
                  Row(
                    children: [
                      if (meal.cuisine.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            meal.cuisine,
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(meal.difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meal.difficulty,
                          style: TextStyle(
                            color: _getDifficultyColor(meal.difficulty),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Nutrition
                  Row(
                    children: [
                      Expanded(
                        child: _buildNutritionItem('Cal', '${meal.calories}', Colors.orange),
                      ),
                      Expanded(
                        child: _buildNutritionItem('Protein', '${meal.protein.toStringAsFixed(0)}g', AppColors.protein),
                      ),
                      Expanded(
                        child: _buildNutritionItem('Carbs', '${meal.carbs.toStringAsFixed(0)}g', AppColors.carbs),
                      ),
                      Expanded(
                        child: _buildNutritionItem('Fat', '${meal.fat.toStringAsFixed(0)}g', AppColors.fat),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Diet indicators
                  Row(
                    children: [
                      if (meal.isVegetarian) _buildDietIndicator('🥬', 'Veg'),
                      if (meal.isVegan) _buildDietIndicator('🌱', 'Vegan'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.circle,
            color: color,
            size: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 8, color: AppColors.textTertiary),
        ),
      ],
    );
  }

  Widget _buildDietIndicator(String emoji, String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Tooltip(
        message: label,
        child: Text(emoji, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.wb_sunny;
      case 'lunch':
        return Icons.wb_sunny_outlined;
      case 'dinner':
        return Icons.nightlight;
      default:
        return Icons.restaurant;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.textSecondary;
    }
  }

  void _speakMealInfo() {
    TTSService.speakMealInfo(meal.name, meal.calories, meal.protein);
  }
}
