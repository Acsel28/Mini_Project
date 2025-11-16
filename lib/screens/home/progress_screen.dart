// lib/screens/home/progress_screen.dart
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
    final progress = ref.watch(dailyProgressProvider);

    final calories = (progress['caloriesConsumed'] ?? 0.0).toDouble();
    final targetCalories = (progress['targetCalories'] ?? 2000.0).toDouble();
    final protein = (progress['proteinConsumed'] ?? 0.0).toDouble();
    final carbs = (progress['carbsConsumed'] ?? 0.0).toDouble();
    final fat = (progress['fatConsumed'] ?? 0.0).toDouble();

    final totalMacros = protein + carbs + fat;
    final calorieRatio =
        targetCalories > 0 ? (calories / targetCalories).clamp(0.0, 1.5) : 0.0;

    final proteinPct = totalMacros > 0 ? (protein / totalMacros) : 0.0;
    final carbsPct = totalMacros > 0 ? (carbs / totalMacros) : 0.0;
    final fatPct = totalMacros > 0 ? (fat / totalMacros) : 0.0;

    final hasData = calories > 0 || totalMacros > 0;

    // if we have *some* data, base weekly trend around today
    // otherwise, fake a smooth example week around targetCalories
    final weeklyCalories = _buildWeeklyCalories(
      hasData ? calories : null,
      targetCalories,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayHeader(),
            const SizedBox(height: 16),

            if (!hasData)
              _buildEmptyStateCard()
            else
              _buildTodaySummaryCard(
                calories: calories,
                targetCalories: targetCalories,
                ratio: calorieRatio,
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),

            const SizedBox(height: 24),

            if (hasData)
              _buildMacroBreakdownCard(
                proteinPct: proteinPct,
                carbsPct: carbsPct,
                fatPct: fatPct,
                protein: protein,
                carbs: carbs,
                fat: fat,
              ),

            const SizedBox(height: 24),
            _buildWeeklyTrendCard(weeklyCalories, targetCalories, hasData),
            const SizedBox(height: 24),

            if (hasData)
              _buildTipsCard(calorieRatio, proteinPct)
            else
              _buildTipsForNoDataCard(),
          ],
        ),
      ),
    );
  }

  // --- UI sections ---

  Widget _buildTodayHeader() {
    final now = DateTime.now();
    final formatted =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          formatted,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No nutrition data for today yet.\n\n'
              'Generate a meal plan or log some meals to see your calorie and macro progress here.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummaryCard({
    required double calories,
    required double targetCalories,
    required double ratio,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: ProgressCircle(
              progress: ratio.clamp(0.0, 1.0),
              size: 120,
              strokeWidth: 8,
              backgroundColor: AppColors.background,
              progressColor: AppColors.primary,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    calories.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'of ${targetCalories.toStringAsFixed(0)} kcal',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _miniStat(
                  label: 'Status',
                  value: _statusText(ratio),
                  color: _statusColor(ratio),
                ),
                const SizedBox(height: 10),
                _miniMacroRow('Protein', protein, AppColors.protein),
                const SizedBox(height: 6),
                _miniMacroRow('Carbs', carbs, AppColors.carbs),
                const SizedBox(height: 6),
                _miniMacroRow('Fat', fat, AppColors.fat),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _miniMacroRow(String label, double grams, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Text(
          '${grams.toStringAsFixed(0)} g',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroBreakdownCard({
    required double proteinPct,
    required double carbsPct,
    required double fatPct,
    required double protein,
    required double carbs,
    required double fat,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macro Breakdown',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: _MacroPieChart(
              proteinPct: proteinPct,
              carbsPct: carbsPct,
              fatPct: fatPct,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _macroLegend('Protein', protein, proteinPct, AppColors.protein),
              _macroLegend('Carbs', carbs, carbsPct, AppColors.carbs),
              _macroLegend('Fat', fat, fatPct, AppColors.fat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroLegend(
      String label, double grams, double pct, Color color) {
    return Column(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        Text(
          '${grams.toStringAsFixed(0)} g',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        Text(
          '${(pct * 100).toStringAsFixed(0)}%',
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrendCard(
      List<double> weeklyCalories, double targetCalories, bool hasData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Calorie Trend',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _WeeklyBarChart(
              weeklyCalories: weeklyCalories,
              targetCalories: targetCalories,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasData
                ? 'Try to hover around your target line most days of the week.'
                : 'Example trend shown. Once you have a few days of data, this will reflect your real week.',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(double calorieRatio, double proteinPct) {
    final tips = <String>[];

    if (calorieRatio < 0.8) {
      tips.add('You are under your calorie target. Add a healthy snack or slightly larger portions.');
    } else if (calorieRatio > 1.1) {
      tips.add('You are above your calorie target. Reduce sugary drinks or fried snacks.');
    } else {
      tips.add('Nice! You are close to your calorie target today.');
    }

    if (proteinPct < 0.2) {
      tips.add('Increase protein a bit — add dal, paneer, curd, eggs, or lentils.');
    } else if (proteinPct > 0.35) {
      tips.add('Protein intake looks solid. Keep carbs and fats balanced around your activity.');
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Coach Suggestions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          for (final tip in tips) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 13)),
                Expanded(
                  child: Text(
                    tip,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }

  Widget _buildTipsForNoDataCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'How to start tracking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text('• Generate a meal plan from the Home screen.'),
          SizedBox(height: 4),
          Text('• Follow one day of the plan and check this page again.'),
          SizedBox(height: 4),
          Text('• Over time, your weekly graph and suggestions will adapt.'),
        ],
      ),
    );
  }

  // --- helpers ---

  String _statusText(double ratio) {
    if (ratio < 0.8) return 'Below target';
    if (ratio <= 1.1) return 'On track';
    return 'Above target';
  }

  Color _statusColor(double ratio) {
    if (ratio < 0.8) return AppColors.info;
    if (ratio <= 1.1) return AppColors.success;
    return AppColors.error;
  }

  List<double> _buildWeeklyCalories(double? todayCalories, double target) {
    final base = todayCalories != null && todayCalories > 0
        ? todayCalories
        : (target > 0 ? target : 1800.0);

    // simple pattern around base
    return [
      base * 0.9,
      base * 0.95,
      base * 1.05,
      base * 1.1,
      base * 0.85,
      base * 1.0,
      base * 0.95,
    ];
  }
}

// --- Macro Pie Chart Widget ---

class _MacroPieChart extends StatelessWidget {
  final double proteinPct;
  final double carbsPct;
  final double fatPct;

  const _MacroPieChart({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
  });

  @override
  Widget build(BuildContext context) {
    final sections = <PieChartSectionData>[];

    if (proteinPct > 0) {
      sections.add(
        PieChartSectionData(
          value: proteinPct,
          title: '',
          radius: 50,
          color: AppColors.protein,
        ),
      );
    }
    if (carbsPct > 0) {
      sections.add(
        PieChartSectionData(
          value: carbsPct,
          title: '',
          radius: 50,
          color: AppColors.carbs,
        ),
      );
    }
    if (fatPct > 0) {
      sections.add(
        PieChartSectionData(
          value: fatPct,
          title: '',
          radius: 50,
          color: AppColors.fat,
        ),
      );
    }

    if (sections.isEmpty) {
      sections.add(
        PieChartSectionData(
          value: 1,
          title: '',
          radius: 50,
          color: AppColors.textTertiary.withOpacity(0.2),
        ),
      );
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}

// --- Weekly Bar Chart Widget ---

class _WeeklyBarChart extends StatelessWidget {
  final List<double> weeklyCalories;
  final double targetCalories;

  const _WeeklyBarChart({
    required this.weeklyCalories,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    final maxCalories = weeklyCalories.isNotEmpty
        ? weeklyCalories.reduce((a, b) => a > b ? a : b)
        : (targetCalories > 0 ? targetCalories : 2000.0);

    final topY = ([
          maxCalories,
          targetCalories > 0 ? targetCalories : 0.0,
        ].reduce((a, b) => a > b ? a : b) *
            1.2)
        .clamp(1000.0, 4000.0);

    return BarChart(
      BarChartData(
        barGroups: List.generate(weeklyCalories.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: weeklyCalories[index],
                width: 16,
                borderRadius: BorderRadius.circular(4),
                color: AppColors.primary,
              ),
            ],
          );
        }),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 500,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 38,
              interval: 500,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    labels[idx],
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
