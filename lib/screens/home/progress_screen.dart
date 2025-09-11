import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/progress_circle.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgress = ref.watch(dailyProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's Overview
            _buildTodaysOverview(context, dailyProgress),
            const SizedBox(height: 24),

            // Macro Breakdown
            _buildMacroBreakdown(context, dailyProgress),
            const SizedBox(height: 24),

            // Weekly Chart
            _buildWeeklyChart(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysOverview(BuildContext context, Map<String, double> progress) {
    final caloriesConsumed = progress['caloriesConsumed'] ?? 0;
    final targetCalories = progress['targetCalories'] ?? 2000;
    final progressPercent = (caloriesConsumed / targetCalories).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: ProgressCircle(
                  progress: progressPercent,
                  size: 120,
                  strokeWidth: 12,
                  backgroundColor: AppColors.background,
                  progressColor: AppColors.primary,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${caloriesConsumed.toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'of ${targetCalories.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      ),
                      const Text(
                        'calories',
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: Column(
                  children: [
                    _buildProgressStat('Consumed', '${caloriesConsumed.toInt()} cal'),
                    const SizedBox(height: 12),
                    _buildProgressStat('Remaining', '${(targetCalories - caloriesConsumed).toInt()} cal'),
                    const SizedBox(height: 12),
                    _buildProgressStat('Progress', '${(progressPercent * 100).toInt()}%'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMacroBreakdown(BuildContext context, Map<String, double> progress) {
    final protein = progress['proteinConsumed'] ?? 0;
    final carbs = progress['carbsConsumed'] ?? 0;
    final fat = progress['fatConsumed'] ?? 0;
    final total = protein + carbs + fat;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macro Breakdown',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          if (total > 0) ...[
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: AppColors.protein,
                      value: protein * 4,
                      title: '${((protein * 4) / (total * 4) * 100).toInt()}%',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: AppColors.carbs,
                      value: carbs * 4,
                      title: '${((carbs * 4) / (total * 4) * 100).toInt()}%',
                      radius: 60,
                    ),
                    PieChartSectionData(
                      color: AppColors.fat,
                      value: fat * 9,
                      title: '${((fat * 9) / ((protein * 4) + (carbs * 4) + (fat * 9)) * 100).toInt()}%',
                      radius: 60,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMacroLegend('Protein', '${protein.toInt()}g', AppColors.protein),
                _buildMacroLegend('Carbs', '${carbs.toInt()}g', AppColors.carbs),
                _buildMacroLegend('Fat', '${fat.toInt()}g', AppColors.fat),
              ],
            ),
          ] else ...[
            const Center(
              child: Column(
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: AppColors.textTertiary),
                  SizedBox(height: 16),
                  Text('No data available', style: TextStyle(color: AppColors.textTertiary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWeeklyChart(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Trend',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Weekly chart coming soon',
                style: TextStyle(color: AppColors.textTertiary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
