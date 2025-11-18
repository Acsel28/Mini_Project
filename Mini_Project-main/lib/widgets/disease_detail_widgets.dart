import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../models/disease_model.dart';

// Main disease detail card
class DiseaseDetailCard extends StatelessWidget {
  final FullDiseaseProfile profile;
  final VoidCallback? onTapDiet;
  final VoidCallback? onTapExercise;

  const DiseaseDetailCard({
    super.key,
    required this.profile,
    this.onTapDiet,
    this.onTapExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.disease.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.disease.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Main focus
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Main Focus: ${profile.getMainFocus()}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Diet and Exercise buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    'Diet',
                    Icons.restaurant,
                    Colors.green,
                    onTapDiet ?? () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    'Exercise',
                    Icons.fitness_center,
                    Colors.orange,
                    onTapExercise ?? () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Diet details widget
class DietDetailsWidget extends StatelessWidget {
  final DietInfo diet;

  const DietDetailsWidget({super.key, required this.diet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            diet.getSummary(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Avoid foods
        if (diet.avoidFoods.isNotEmpty) ...[
          _buildFoodSection(
            'Foods to Avoid',
            diet.avoidFoods,
            Colors.red,
            Icons.close_rounded,
          ),
          const SizedBox(height: 16),
        ],

        // Recommended foods
        if (diet.recommendedFoods.isNotEmpty) ...[
          _buildFoodSection(
            'Recommended Foods',
            diet.recommendedFoods,
            Colors.green,
            Icons.check_circle_rounded,
          ),
          const SizedBox(height: 16),
        ],

        // Macros
        if (diet.macros.isNotEmpty) ...[
          _buildMacrosSection(),
          const SizedBox(height: 16),
        ],

        // Constraints
        if (diet.constraints.isNotEmpty) ...[
          _buildConstraintsSection(),
        ],
      ],
    );
  }

  Widget _buildFoodSection(
    String title,
    List<String> foods,
    Color color,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: foods.map((food) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                food,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMacrosSection() {
    final macros = diet.macros;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nutritional Targets',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              if (macros['protein_pct'] != null)
                _buildMacroRow('Protein', macros['protein_pct'], Colors.red),
              if (macros['carbs_pct'] != null)
                _buildMacroRow('Carbohydrates', macros['carbs_pct'], Colors.blue),
              if (macros['fat_pct'] != null)
                _buildMacroRow('Fat', macros['fat_pct'], Colors.yellow[700]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroRow(String label, dynamic value, Color? color) {
    String displayValue = '';
    if (value is List && value.length >= 2) {
      displayValue = '${value[0]}-${value[1]}%';
    } else {
      displayValue = '$value%';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (color ?? Colors.grey).withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dietary Guidelines',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...diet.constraints.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${entry.key.replaceAll('_', ' ')}: ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Exercise details widget
class ExerciseDetailsWidget extends StatelessWidget {
  final ExerciseRecommendations recommendations;

  const ExerciseDetailsWidget({super.key, required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            recommendations.getSummary(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recommended exercises
        if (recommendations.recommendedExercises.isNotEmpty) ...[
          _buildExerciseSection(
            'Recommended Exercises',
            recommendations.recommendedExercises,
            Colors.green,
          ),
          const SizedBox(height: 16),
        ],

        // Exercises to avoid
        if (recommendations.exercisesToAvoid.isNotEmpty) ...[
          _buildExerciseSection(
            'Exercises to Avoid',
            recommendations.exercisesToAvoid,
            Colors.red,
          ),
          const SizedBox(height: 16),
        ],

        // Warnings
        if (recommendations.warnings.isNotEmpty) ...[
          _buildWarningsSection(),
        ],
      ],
    );
  }

  Widget _buildExerciseSection(
    String title,
    List<Exercise> exercises,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              title.contains('Avoid') ? Icons.block : Icons.check_circle,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${exercises.length}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...exercises.map((exercise) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(exercise.difficulty).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exercise.difficulty,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getDifficultyColor(exercise.difficulty),
                        ),
                      ),
                    ),
                  ],
                ),
                if (exercise.equipment != null && exercise.equipment!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Equipment: ${exercise.equipment}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
                if (exercise.muscles.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    children: exercise.muscles.map((muscle) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          muscle,
                          style: const TextStyle(fontSize: 10, color: Colors.purple),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildWarningsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Important Notes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendations.warnings.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '• ${entry.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// Lifestyle guidance widget
class LifestyleGuidanceWidget extends StatelessWidget {
  final LifestyleGuidance guidance;

  const LifestyleGuidanceWidget({super.key, required this.guidance});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tips
        if (guidance.tips.isNotEmpty) ...[
          const Text(
            'Lifestyle Tips',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          ...guidance.tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.teal, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
        ],

        // Monitoring
        if (guidance.monitoring.trackingPoints.isNotEmpty) ...[
          const Text(
            'What to Track',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: guidance.monitoring.trackingPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
