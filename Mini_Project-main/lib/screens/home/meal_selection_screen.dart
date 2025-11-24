import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../models/ai_content_models.dart';
import '../../providers/ai_content_provider.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/wellness_scaffold.dart';

// State provider for selected meal type
final selectedMealTypeProvider = StateProvider<String>((ref) => 'breakfast');

class MealSelectionScreen extends ConsumerWidget {
  const MealSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMealType = ref.watch(selectedMealTypeProvider);
    final mealsAsync = ref.watch(mealStudioIdeasProvider(selectedMealType));

    return WellnessScaffold(
      title: 'Meal studio',
      subtitle: 'Curate chef-guided options for every part of the day',
      body: Column(
        children: [
          SegmentedButton<String>(
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
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return AppColors.surfaceAlt;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return AppColors.textSecondary;
              }),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: mealsAsync.when(
              data: (ideas) {
                if (ideas.isEmpty) {
                  return _buildEmptyState('No $selectedMealType ideas yet. Refresh to try new prompts.');
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: ideas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return _buildMealCard(context, ref, ideas[index], selectedMealType);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _buildEmptyState('Error loading meals\n${error.toString()}'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, WidgetRef ref, MealStudioIdea idea, String mealType) {
    final protein = (idea.macros['protein'] ?? 0).toInt();
    final carbs = (idea.macros['carbs'] ?? 0).toInt();
    final fat = (idea.macros['fat'] ?? 0).toInt();

    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: AppInsets.card,
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  idea.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent1.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '${idea.calories} cal',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.accent1,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          if (idea.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              idea.description,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMacroLabel('Protein', protein, 'g'),
              _buildMacroLabel('Carbs', carbs, 'g'),
              _buildMacroLabel('Fat', fat, 'g'),
            ],
          ),
          if (idea.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: idea.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  backgroundColor: AppColors.surfaceAlt,
                  labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final meal = idea.toMeal(slot: mealType);
                final success = await ref.read(mealPlanProvider.notifier).logMeal(meal, slot: mealType);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '${idea.name} logged for ${mealType.toUpperCase()}. Calorie progress updated.'
                          : 'Could not log that meal. Please try again.',
                    ),
                    backgroundColor: success ? AppColors.primary : AppColors.error,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Select meal'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroLabel(String label, dynamic value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$value$unit',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.restaurant, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
