import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system.dart';
import '../../core/theme.dart';
import '../../services/insights_service.dart';
import '../../providers/health_logging_provider.dart';
import '../../providers/chatbot_provider.dart';
import '../../widgets/wellness_scaffold.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
    Widget _buildChatbotResponsesSection() {
      final chatbotResponsesAsync = ref.watch(chatbotResponsesProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Health Coach Responses',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),
          chatbotResponsesAsync.when(
            data: (responses) {
              if (responses.isEmpty) {
                return const Text('No chatbot responses yet. Answer questions in the Coach tab!');
              }
              return Column(
                children: responses.map((r) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: AppStyles.cardDecoration.copyWith(borderRadius: AppRadius.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.questionText.isNotEmpty ? r.questionText : 'Question #${r.questionId}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text('Your answer: ${r.selectedOption}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Coach reply: ${r.answer}', style: const TextStyle(color: AppColors.primary)),
                      const SizedBox(height: 4),
                      Text('Time: ${r.createdAt.toLocal()}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading chatbot responses: $e'),
          ),
        ],
      );
    }
  Map<String, dynamic>? _dynamicInsights;
  Map<String, dynamic>? _trends;
  Map<String, dynamic>? _prediction;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Load health metrics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthLoggingProvider.notifier).loadDailySummary();
    });
  }

  Future<void> _fetchData() async {
    setState(() => _loading = true);
    final dynamicInsights = await InsightsService.getDynamicInsights();
    final trends = await InsightsService.getTrends();
    final prediction = await InsightsService.getPrediction();
    setState(() {
      _dynamicInsights = dynamicInsights;
      _trends = trends;
      _prediction = prediction;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final healthMetrics = ref.watch(healthLoggingProvider);

    return WellnessScaffold(
      title: 'Insights & biometrics',
      subtitle: 'AI reflections on your latest logs',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _fetchData,
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildHealthMetricsSection(healthMetrics),
                  const SizedBox(height: 20),
                  _buildChatbotResponsesSection(),
                  const SizedBox(height: 20),
                  if (_dynamicInsights != null && (_dynamicInsights!['insights'] as List).isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Your Health Insights',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_dynamicInsights!['insights'] as List<dynamic>).map((insight) => _buildInsightCard(insight)),
                    const SizedBox(height: 20),
                  ] else ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(16),
                      decoration: AppStyles.cardDecoration,
                      child: Column(
                        children: const [
                          Icon(Icons.info_outline, size: 48, color: AppColors.accent2),
                          SizedBox(height: 12),
                          Text(
                            'No health data yet',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Log hydration or sleep to unlock precision insights.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_dynamicInsights != null && _dynamicInsights!['metrics'] != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Today\'s metrics',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(_dynamicInsights!['metrics']),
                    const SizedBox(height: 20),
                  ],
                  if (_trends != null && _trends!['trends'] != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Weekly trends',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...(_trends!['trends'] as List<dynamic>).map((trend) => _buildTrendChart(trend, _trends!['labels'])),
                    const SizedBox(height: 20),
                  ],
                  if (_prediction != null && _prediction!['prediction'] != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text(
                        'Weight projection',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(_prediction!['prediction']['message'] ?? '', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildPredictionChart(_prediction!['prediction']),
                    const SizedBox(height: 20),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('Export data (PDF/CSV)'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Export coming soon!')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthMetricsSection(HealthMetrics healthMetrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Real-Time Health Metrics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                'Water Intake',
                '${healthMetrics.waterLogged} ml',
                '${healthMetrics.waterPercentage.toStringAsFixed(0)}% of goal',
                Colors.blue,
                Icons.local_drink,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthMetricCard(
                'Sleep',
                '${healthMetrics.sleepLogged.toStringAsFixed(1)} hrs',
                '${healthMetrics.sleepPercentage.toStringAsFixed(0)}% of goal',
                Colors.purple,
                Icons.bedtime,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard(
    String title,
    String value,
    String percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: AppRadius.lg,
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.18), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              percentage,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(dynamic insight) {
    Color bgColor = Colors.green[100] ?? Colors.green;
    Color textColor = Colors.green;
    IconData icon = Icons.check_circle;

    if (insight['type'] == 'warning') {
      bgColor = Colors.orange[100] ?? Colors.orange;
      textColor = Colors.orange;
      icon = Icons.warning;
    } else if (insight['type'] == 'alert') {
      bgColor = Colors.red[100] ?? Colors.red;
      textColor = Colors.red;
      icon = Icons.error;
    } else if (insight['type'] == 'info') {
      bgColor = Colors.blue[100] ?? Colors.blue;
      textColor = Colors.blue;
      icon = Icons.info;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: AppRadius.lg,
        gradient: LinearGradient(
          colors: [bgColor, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  insight['title'] ?? 'Insight',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            insight['message'] ?? '',
            style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> metrics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard('Water Today', '${(metrics['todayWater'] ?? 0) / 1000} L', Colors.blue),
        _buildMetricCard('Sleep Today', '${metrics['todaySleep'] ?? 0} hrs', Colors.purple),
        _buildMetricCard('Weekly Avg Water', '${(metrics['weeklyHydrationAverage'] ?? 0) / 1000} L', Colors.cyan),
        _buildMetricCard('Weekly Avg Sleep', '${metrics['weeklySleepAverage'] ?? 0} hrs', Colors.indigo),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: AppRadius.lg,
        gradient: LinearGradient(
          colors: [Colors.white, color.withValues(alpha: 0.08)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(dynamic trend, List<dynamic> labels) {
    final values = (trend['data'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    final maxValue = values.isEmpty ? 0.0 : values.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration.copyWith(borderRadius: AppRadius.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(trend['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...List.generate(values.length, (i) {
            final progress = maxValue == 0 ? 0.0 : (values[i] / maxValue).clamp(0.0, 1.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(labels[i].toString(), style: const TextStyle(color: AppColors.textSecondary)),
                      Text('${values[i].toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: AppRadius.pill,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceAlt,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary.withValues(alpha: 0.8)),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPredictionChart(dynamic prediction) {
    final weights = (prediction['weightProjection'] as List<dynamic>).map((e) => (e as num).toDouble()).toList();
    final maxWeight = weights.isEmpty ? 0.0 : weights.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration.copyWith(borderRadius: AppRadius.lg),
      child: Column(
        children: List.generate(weights.length, (i) {
          final progress = maxWeight == 0 ? 0.0 : (weights[i] / maxWeight).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(prediction['labels'][i], style: const TextStyle(color: AppColors.textSecondary)),
                    Text('${weights[i].toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary.withValues(alpha: 0.9)),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
