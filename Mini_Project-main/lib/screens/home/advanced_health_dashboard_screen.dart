import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/reusable_components.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/voice_assistant_widget.dart';

import 'package:fl_chart/fl_chart.dart';
import '../../widgets/quick_action_button.dart';
// import '../../widgets/app_styles_extended.dart';

class AdvancedHealthDashboardScreen extends ConsumerStatefulWidget {
  const AdvancedHealthDashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdvancedHealthDashboardScreen> createState() =>
      _AdvancedHealthDashboardScreenState();
}

class _AdvancedHealthDashboardScreenState
    extends ConsumerState<AdvancedHealthDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final statsAsync = ref.watch(userStatsProvider);
    final recommendationsAsync = ref.watch(healthRecommendationsProvider);

    // Dummy weekly data for chart
    final List<double> weeklyCalories = [1800, 1950, 2000, 1750, 2100, 1850, 1900];
    final List<String> weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Dashboard'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userStatsProvider);
          ref.invalidate(healthRecommendationsProvider);
          ref.invalidate(healthInsightsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Voice Assistant Widget
              const VoiceAssistantWidget(),

              // Quick Actions Row
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    QuickActionButton(
                      icon: Icons.restaurant,
                      label: 'Log Meal',
                      color: Colors.deepOrange,
                      onPressed: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.monitor_weight,
                      label: 'Add Weight',
                      color: Colors.blue,
                      onPressed: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.flag,
                      label: 'Set Goal',
                      color: Colors.green,
                      onPressed: () {},
                    ),
                    QuickActionButton(
                      icon: Icons.nightlight,
                      label: 'Dark Mode',
                      color: Colors.purple,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // User greeting section
              if (user != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${user.name}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Here\'s your health overview',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              // Stats Section
              Text(
                'Your Metrics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              statsAsync.when(
                data: (stats) {
                  if (stats == null) {
                    return EmptyState(
                      icon: Icons.error,
                      title: 'Unable to Load Stats',
                      message: 'Please try again',
                      onButtonTap: () {
                        ref.invalidate(userStatsProvider);
                      },
                    );
                  }

                  final metrics = stats['metrics'] as Map<String, dynamic>?;
                  final bmi = metrics?['bmi'] as double? ?? 0.0;
                  final bmr = metrics?['bmr'] as double? ?? 0.0;
                  final tdee = metrics?['tdee'] as double? ?? 0.0;
                  final calories = metrics?['calories'] as double? ?? 1850.0;
                  final protein = metrics?['protein'] as double? ?? 90.0;
                  final carbs = metrics?['carbs'] as double? ?? 220.0;
                  final fat = metrics?['fat'] as double? ?? 60.0;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedProgressBar('Calories', calories, 2000, Colors.deepOrange, Icons.local_fire_department),
                      _buildAnimatedProgressBar('Protein', protein, 120, Colors.blue, Icons.fitness_center),
                      _buildAnimatedProgressBar('Carbs', carbs, 250, Colors.green, Icons.bubble_chart),
                      _buildAnimatedProgressBar('Fat', fat, 70, Colors.purple, Icons.oil_barrel),
                      const SizedBox(height: 18),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          StatsCard(
                            label: 'BMI',
                            value: bmi.toStringAsFixed(1),
                            unit: 'kg/m²',
                            color: _getBMIColor(bmi),
                            icon: Icons.monitor_weight,
                          ),
                          StatsCard(
                            label: 'BMR',
                            value: bmr.toStringAsFixed(0),
                            unit: 'kcal/day',
                            color: Colors.blue,
                            icon: Icons.local_fire_department,
                          ),
                          StatsCard(
                            label: 'TDEE',
                            value: tdee.toStringAsFixed(0),
                            unit: 'kcal/day',
                            color: Colors.green,
                            icon: Icons.flash_on,
                          ),
                          StatsCard(
                            label: 'Target',
                            value: (stats['user']['targetCalories'] as int?)?.toString() ?? '2000',
                            unit: 'kcal/day',
                            color: Colors.orange,
                            icon: Icons.gps_fixed,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text('Weekly Calories', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 180,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true, drawVerticalLine: false),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    int idx = value.toInt();
                                    if (idx >= 0 && idx < weekDays.length) {
                                      return Text(weekDays[idx], style: const TextStyle(fontSize: 12));
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 6,
                            minY: 1500,
                            maxY: 2200,
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(weeklyCalories.length, (i) => FlSpot(i.toDouble(), weeklyCalories[i])),
                                isCurved: true,
                                color: Colors.deepOrange,
                                barWidth: 4,
                                dotData: FlDotData(show: true),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          _buildAchievementCard('7-Day Streak', Icons.emoji_events, Colors.amber, 'Keep it up!'),
                          const SizedBox(width: 12),
                          _buildAchievementCard('Goal Reached', Icons.star, Colors.green, 'Congrats!'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _buildGoalBanner(),
                      const SizedBox(height: 32),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Error: $err'),
                ),
              ),

              // Recommendations Section
              Text(
                'Health Recommendations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              recommendationsAsync.when(
                data: (recommendations) {
                  if (recommendations == null || recommendations.isEmpty) {
                    return const Text('No recommendations available');
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendations.length,
                    itemBuilder: (context, index) {
                      return _buildInsightCard(context, recommendations[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Text('Error: $err'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildAnimatedProgressBar(String label, double value, double max, Color color, IconData icon) {
    final percent = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${value.toInt()} / ${max.toInt()}', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 10,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, Map<String, dynamic> insight) {
    final type = insight['type'] as String? ?? 'info';
    final title = insight['title'] as String? ?? 'Insight';
    final message = insight['message'] as String? ?? '';

    final typeColor = _getInsightColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: typeColor, width: 4),
        ),
        borderRadius: BorderRadius.circular(6),
        color: typeColor.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: typeColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Color _getInsightColor(String type) {
    switch (type) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  Widget _buildAchievementCard(String title, IconData icon, Color color, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Daily Goal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text('Stay under 2000 calories and log all meals today!', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
