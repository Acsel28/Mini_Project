import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/health_logging_provider.dart';

class HydrationSleepWidget extends ConsumerStatefulWidget {
  const HydrationSleepWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<HydrationSleepWidget> createState() => _HydrationSleepWidgetState();
}

class _HydrationSleepWidgetState extends ConsumerState<HydrationSleepWidget> {
  final TextEditingController _waterController = TextEditingController();
  final TextEditingController _sleepController = TextEditingController();
  final TextEditingController _sleepQualityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load initial health data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthLoggingProvider.notifier).loadDailySummary();
    });
  }

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _sleepQualityController.dispose();
    super.dispose();
  }

  Future<void> _logWater() async {
    final amount = int.tryParse(_waterController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    final success = await ref.read(healthLoggingProvider.notifier).logWater(amount);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Water logged successfully!')),
      );
      _waterController.clear();
      // Reload data
      await ref.read(healthLoggingProvider.notifier).loadDailySummary();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log water')),
      );
    }
  }

  Future<void> _logSleep() async {
    final hours = double.tryParse(_sleepController.text);
    if (hours == null || hours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid number of hours')),
      );
      return;
    }

    final quality = _sleepQualityController.text.isEmpty ? 'good' : _sleepQualityController.text;
    final success = await ref.read(healthLoggingProvider.notifier).logSleep(hours, quality: quality);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Sleep logged successfully!')),
      );
      _sleepController.clear();
      _sleepQualityController.clear();
      // Reload data
      await ref.read(healthLoggingProvider.notifier).loadDailySummary();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log sleep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final healthMetrics = ref.watch(healthLoggingProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hydration & Sleep Tracking',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),

            // Hydration Summary
            _buildMetricCard(
              'Water Intake',
              '${healthMetrics.waterLogged} / ${healthMetrics.waterGoal} ml',
              healthMetrics.waterPercentage,
              Colors.blue,
              Icons.local_drink,
            ),
            const SizedBox(height: 12),

            // Sleep Summary
            _buildMetricCard(
              'Sleep Duration',
              '${healthMetrics.sleepLogged.toStringAsFixed(1)} / ${healthMetrics.sleepGoal.toInt()} hours',
              healthMetrics.sleepPercentage,
              Colors.purple,
              Icons.bedtime,
            ),
            const SizedBox(height: 16),

            // Water input section
            Text(
              'Log Water',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Amount (ml)',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 250',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: healthMetrics.isLoading ? null : _logWater,
                  child: healthMetrics.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Log'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sleep input section
            Text(
              'Log Sleep',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _sleepController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Hours',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., 8.5',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _sleepQualityController,
                    decoration: const InputDecoration(
                      labelText: 'Quality',
                      border: OutlineInputBorder(),
                      hintText: 'good/fair/poor',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: healthMetrics.isLoading ? null : _logSleep,
                child: healthMetrics.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Log Sleep'),
              ),
            ),

            if (healthMetrics.error != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: ${healthMetrics.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    double percentage,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${percentage.toStringAsFixed(0)}% of daily goal',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
