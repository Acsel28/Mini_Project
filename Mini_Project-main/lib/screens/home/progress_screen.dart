import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../providers/meal_provider.dart';
import '../../widgets/progress_circle.dart';
import '../../widgets/wellness_scaffold.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyProgress = ref.watch(dailyProgressProvider);

    return WellnessScaffold(
      title: 'Progress',
      subtitle: 'Macro trends & weekly wins',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodaysOverview(context, dailyProgress),
            const SizedBox(height: 24),
            _buildMacroBreakdown(context, dailyProgress),
            const SizedBox(height: 24),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.8),
        borderRadius: AppRadius.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
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
    const weeklyCalories = [1780.0, 2020.0, 1950.0, 2105.0, 1880.0, 2190.0, 2005.0];
    const calorieGoal = 2000.0;

    final spots = List.generate(
      weeklyCalories.length,
      (index) => FlSpot(index.toDouble(), weeklyCalories[index]),
    );

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
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 1500,
                maxY: 2400,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: Color(0xFFE3ECF5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                        if (value.toInt() < 0 || value.toInt() >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[value.toInt()],
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 4,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: List.generate(weeklyCalories.length, (index) => FlSpot(index.toDouble(), calorieGoal)),
                    isCurved: false,
                    color: AppColors.secondary.withValues(alpha: 0.7),
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _LegendDot(color: AppColors.primary, label: 'Actual intake'),
              _LegendDot(color: AppColors.secondary, label: 'Calorie target'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}
