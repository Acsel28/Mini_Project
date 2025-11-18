import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../models/meal_model.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/app_styles_extended.dart';
import '../../widgets/reusable_components.dart';

class NutritionAnalyticsScreen extends ConsumerStatefulWidget {
  const NutritionAnalyticsScreen({super.key});

  @override
  ConsumerState<NutritionAnalyticsScreen> createState() =>
      _NutritionAnalyticsScreenState();
}

class _NutritionAnalyticsScreenState
    extends ConsumerState<NutritionAnalyticsScreen> {
  @override
  Widget build(BuildContext context) {
    final mealPlan = ref.watch(mealPlanProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nutrition Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => _showDatePicker(context),
            tooltip: 'Select Date',
          ),
        ],
      ),
      body: mealPlan == null
          ? EmptyState(
              icon: Icons.analytics_outlined,
              title: 'No Meal Data',
              message: 'Start logging meals to see analytics',
              buttonText: 'Plan Meals',
            )
          : SingleChildScrollView(
              padding: PaddingValues.lg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Daily Summary
                  _buildDailySummary(mealPlan),
                  AppStylesExtended.gapXxl,

                  // Macronutrient Breakdown
                  _buildMacroBreakdown(mealPlan),
                  AppStylesExtended.gapXxl,

                  // Nutritional Details
                  _buildNutritionalDetails(mealPlan),
                  AppStylesExtended.gapXxl,

                  // Meal Timeline
                  _buildMealTimeline(mealPlan),
                  AppStylesExtended.gapXxl,

                  // Insights
                  _buildInsights(mealPlan),
                ],
              ),
            ),
    );
  }

  Widget _buildDailySummary(MealPlan mealPlan) {
    final totalCalories = mealPlan.totalCalories;
    const dailyTarget = 2000;
    final percentageOfTarget = (totalCalories / dailyTarget * 100).clamp(0, 200);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Today\'s Summary'),
        AppStylesExtended.gapLg,
        Container(
          padding: PaddingValues.lg,
          decoration: AppStylesExtended.containerDecoration,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Calories',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        AppStylesExtended.gapMd,
                        Text(
                          '${totalCalories.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        AppStylesExtended.gapSm,
                        Text(
                          'of $dailyTarget kcal/day',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircularProgressIndicator(
                              value:
                                  (percentageOfTarget / 100).clamp(0.0, 1.0),
                              strokeWidth: 8,
                              backgroundColor: AppColors.background,
                              valueColor: AlwaysStoppedAnimation(
                                percentageOfTarget <= 100
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                          Text(
                            '${percentageOfTarget.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      AppStylesExtended.gapMd,
                      if (totalCalories < dailyTarget)
                        Text(
                          '${(dailyTarget - totalCalories).toStringAsFixed(0)} kcal left',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      else
                        Text(
                          '+${(totalCalories - dailyTarget).toStringAsFixed(0)} kcal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBreakdown(MealPlan mealPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Macronutrient Breakdown'),
        AppStylesExtended.gapLg,
        Container(
          padding: PaddingValues.lg,
          decoration: AppStylesExtended.containerDecoration,
          child: Column(
            children: [
              MacroDisplay(
                label: 'Protein',
                value: mealPlan.totalProtein,
                target: 150,
                color: AppColors.protein,
              ),
              AppStylesExtended.gapLg,
              MacroDisplay(
                label: 'Carbohydrates',
                value: mealPlan.totalCarbs,
                target: 250,
                color: AppColors.carbs,
              ),
              AppStylesExtended.gapLg,
              MacroDisplay(
                label: 'Fats',
                value: mealPlan.totalFat,
                target: 65,
                color: AppColors.fat,
              ),
              AppStylesExtended.gapLg,
              // Macro percentages
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroPercentage('Protein', mealPlan.totalProtein * 4,
                      mealPlan.totalCalories.toDouble()),
                  _buildMacroPercentage(
                      'Carbs',
                      mealPlan.totalCarbs * 4,
                      mealPlan.totalCalories.toDouble()),
                  _buildMacroPercentage('Fat', mealPlan.totalFat * 9,
                      mealPlan.totalCalories.toDouble()),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacroPercentage(String label, double calories, double total) {
    final percentage = total > 0 ? (calories / total * 100).clamp(0, 100) : 0;
    return Column(
      children: [
        Text(
          '${percentage.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        AppStylesExtended.gapSm,
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionalDetails(MealPlan mealPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Nutritional Details'),
        AppStylesExtended.gapLg,
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppStylesExtended.md,
          mainAxisSpacing: AppStylesExtended.md,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            StatsCard(
              label: 'Fiber',
              value: '25',
              unit: 'g',
              icon: Icons.eco,
              color: AppColors.success,
            ),
            StatsCard(
              label: 'Sodium',
              value: '1500',
              unit: 'mg',
              icon: Icons.water_drop,
              color: AppColors.warning,
            ),
            StatsCard(
              label: 'Calcium',
              value: '800',
              unit: 'mg',
              icon: Icons.favorite,
              color: AppColors.primary,
            ),
            StatsCard(
              label: 'Iron',
              value: '15',
              unit: 'mg',
              icon: Icons.energy_savings_leaf,
              color: AppColors.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealTimeline(MealPlan mealPlan) {
    final meals = [
      ('Breakfast', mealPlan.breakfast, Icons.breakfast_dining, AppColors.accent1),
      ('Lunch', mealPlan.lunch, Icons.lunch_dining, AppColors.accent2),
      ('Dinner', mealPlan.dinner, Icons.dinner_dining, AppColors.accent3),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Meal Timeline'),
        AppStylesExtended.gapLg,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: meals.length,
          separatorBuilder: (_, __) => AppStylesExtended.gapMd,
          itemBuilder: (context, index) {
            final (mealType, meal, icon, color) = meals[index];
            if (meal == null) {
              return _buildMealTimelineCard(
                mealType,
                'Not logged',
                0,
                0,
                icon,
                color,
              );
            }
            return _buildMealTimelineCard(
              mealType,
              meal.name,
              meal.calories.toDouble(),
              meal.protein.toDouble(),
              icon,
              color,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMealTimelineCard(
    String mealType,
    String mealName,
    double calories,
    double protein,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: PaddingValues.lg,
      decoration: AppStylesExtended.containerDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.light,
              borderRadius: BorderRadius.circular(AppStylesExtended.radiusMd),
            ),
            child: Icon(icon, color: color),
          ),
          AppStylesExtended.gapHLg,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                AppStylesExtended.gapSm,
                Text(
                  mealName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              AppStylesExtended.gapSm,
              Text(
                '${protein.toStringAsFixed(0)}g protein',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsights(MealPlan mealPlan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Insights'),
        AppStylesExtended.gapLg,
        FeatureCard(
          icon: Icons.lightbulb_outline,
          title: 'Balanced Nutrition',
          description:
              'Your macros look balanced today! Keep maintaining this ratio.',
          backgroundColor: AppColors.primary,
          onTap: () {},
        ),
        AppStylesExtended.gapMd,
        FeatureCard(
          icon: Icons.trending_up,
          title: 'Protein Goals',
          description:
              'Great job! You\'ve hit ${(mealPlan.totalProtein / 150 * 100).toStringAsFixed(0)}% of your protein target.',
          backgroundColor: AppColors.success,
          onTap: () {},
        ),
      ],
    );
  }

  void _showDatePicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
  }
}
