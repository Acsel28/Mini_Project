import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design_system.dart';
import '../core/theme.dart';
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

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.surfaceAlt.withValues(alpha: 0.8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hydration & sleep',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => ref.read(healthLoggingProvider.notifier).loadDailySummary(),
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Water intake',
                  value: '${healthMetrics.waterLogged}/${healthMetrics.waterGoal} ml',
                  percent: healthMetrics.waterPercentage / 100,
                  color: Colors.blueAccent,
                  icon: Icons.local_drink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricPill(
                  label: 'Sleep duration',
                  value: '${healthMetrics.sleepLogged.toStringAsFixed(1)}/${healthMetrics.sleepGoal.toInt()} h',
                  percent: healthMetrics.sleepPercentage / 100,
                  color: Colors.purple,
                  icon: Icons.bedtime,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Log water',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _waterController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (ml)',
                    hintText: 'e.g., 250',
                    filled: true,
                    fillColor: AppColors.surface,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.surfaceAlt),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: healthMetrics.isLoading ? null : _logWater,
                child: healthMetrics.isLoading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Log'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Log sleep',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _sleepController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Hours',
                    hintText: 'e.g., 7.5',
                    filled: true,
                    fillColor: AppColors.surface,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.surfaceAlt),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _sleepQualityController,
                  decoration: InputDecoration(
                    labelText: 'Quality',
                    hintText: 'good/fair/poor',
                    filled: true,
                    fillColor: AppColors.surface,
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    hintStyle: const TextStyle(color: AppColors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.surfaceAlt),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: AppRadius.md,
                      borderSide: BorderSide(color: AppColors.primary, width: 1.4),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: healthMetrics.isLoading ? null : _logSleep,
              child: healthMetrics.isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save sleep'),
            ),
          ),
          if (healthMetrics.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: AppRadius.md,
              ),
              child: Text(
                healthMetrics.error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    required this.value,
    required this.percent,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final double percent;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final displayPercent = percent.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppStyles.cardDecoration.copyWith(
        borderRadius: AppRadius.lg,
        gradient: LinearGradient(
          colors: [Colors.white, color.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 10,
            child: ClipRRect(
              borderRadius: AppRadius.pill,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: displayPercent),
                duration: AppDurations.regular,
                curve: Curves.easeInOut,
                builder: (context, value, _) {
                  return LinearProgressIndicator(
                    value: value,
                    minHeight: 10,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
