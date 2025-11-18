import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/insights_service.dart';
import '../../providers/health_logging_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/chatbot_provider.dart';

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
                children: responses.map((r) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(r.questionText.isNotEmpty ? r.questionText : 'Question #${r.questionId}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Your answer: ${r.selectedOption}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Coach reply: ${r.answer}', style: const TextStyle(color: Colors.teal)),
                        Text('Time: ${r.createdAt.toLocal()}'),
                      ],
                    ),
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
    final user = ref.watch(userProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights & Health Data'),
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepOrange))
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Real-time water and sleep data
                  _buildHealthMetricsSection(healthMetrics),
                  const SizedBox(height: 24),

                  // Chatbot Responses Section
                  _buildChatbotResponsesSection(),
                  const SizedBox(height: 24),

                  // Dynamic Health Insights Section
                  if (_dynamicInsights != null && (_dynamicInsights!['insights'] as List).isNotEmpty) ...[
                    const Text(
                      'Your Health Insights',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ...(_dynamicInsights!['insights'] as List<dynamic>).map((insight) => _buildInsightCard(insight)),
                    const SizedBox(height: 24),
                  ] else ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, size: 48, color: Colors.orange),
                            const SizedBox(height: 12),
                            const Text(
                              'No health data yet',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Log your water intake and sleep to see personalized insights!',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Metrics Summary
                  if (_dynamicInsights != null && _dynamicInsights!['metrics'] != null) ...[
                    const Text(
                      'Today\'s Metrics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    _buildMetricsGrid(_dynamicInsights!['metrics']),
                    const SizedBox(height: 24),
                  ],

                  // Weekly Trends
                  if (_trends != null && _trends!['trends'] != null) ...[
                    const Text(
                      'Weekly Trends',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    ...(_trends!['trends'] as List<dynamic>).map((trend) => _buildTrendChart(trend, _trends!['labels'])),
                    const SizedBox(height: 24),
                  ],

                  // Weight Prediction
                  if (_prediction != null && _prediction!['prediction'] != null) ...[
                    const Text(
                      'Weight Projection',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 12),
                    Text(_prediction!['prediction']['message'] ?? '', style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    _buildPredictionChart(_prediction!['prediction']),
                    const SizedBox(height: 24),
                  ],

                  // Export Button
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('Export Data (PDF/CSV)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Export coming soon!'))
                      );
                    },
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
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border(
            left: BorderSide(color: textColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: textColor),
                  const SizedBox(width: 8),
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
              const SizedBox(height: 8),
              Text(
                insight['message'] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
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
    return Card(
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildTrendChart(dynamic trend, List<dynamic> labels) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trend['label'], style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(trend['data'].length, (i) => Expanded(
                child: Column(
                  children: [
                    Text('${trend['data'][i]}', style: const TextStyle(fontSize: 14)),
                    Text(labels[i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionChart(dynamic prediction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: List.generate(prediction['weightProjection'].length, (i) => Expanded(
            child: Column(
              children: [
                Text('${prediction['weightProjection'][i]}', style: const TextStyle(fontSize: 14)),
                Text(prediction['labels'][i], style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          )),
        ),
      ),
    );
  }


  Widget _buildChatbotResponseCard(dynamic response) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Question',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        response.questionText,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Choice',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    response.selectedOption,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF4DB8C4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Advice',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    response.answer,
                    style: const TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
