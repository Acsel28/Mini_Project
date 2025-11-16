import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/exercise_model.dart';
import '../providers/exercise_provider.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  String _mode = 'general'; // 'general' or 'disease'
  String _selectedCondition = 'diabetes';

  final List<Map<String, String>> _conditions = const [
    {'key': 'diabetes', 'label': 'Diabetes'},
    {'key': 'hypertension', 'label': 'Hypertension'},
    {'key': 'obesity', 'label': 'Obesity / Weight'},
    {'key': 'pcos', 'label': 'PCOS'},
    {'key': 'heart', 'label': 'Heart'},
  ];

  @override
  void initState() {
    super.initState();
    // General plan is loaded by default in provider constructor
  }

  void _onModeChanged(String mode) {
    setState(() => _mode = mode);
    if (mode == 'general') {
      ref.read(exerciseProvider.notifier).loadGeneralExercises();
    } else {
      ref
          .read(exerciseProvider.notifier)
          .loadForCondition(_selectedCondition);
    }
  }

  void _onConditionChanged(String conditionKey) {
    setState(() => _selectedCondition = conditionKey);
    if (_mode == 'disease') {
      ref.read(exerciseProvider.notifier).loadForCondition(conditionKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exerciseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode toggle
            Row(
              children: [
                ChoiceChip(
                  label: const Text('General'),
                  selected: _mode == 'general',
                  onSelected: (_) => _onModeChanged('general'),
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Disease-Specific'),
                  selected: _mode == 'disease',
                  onSelected: (_) => _onModeChanged('disease'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Condition selector (only when disease mode)
            if (_mode == 'disease') ...[
              const Text(
                'Select condition',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _conditions
                    .map(
                      (c) => ChoiceChip(
                        label: Text(c['label']!),
                        selected: _selectedCondition == c['key'],
                        onSelected: (_) => _onConditionChanged(c['key']!),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            const Text(
              'Recommended Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: exercisesAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No exercises found.'),
                    );
                  }
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final ex = list[index];
                      return _buildExerciseCard(ex);
                    },
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'Failed to load exercises:\n$e',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise ex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ex.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${ex.duration} • ${ex.intensity} • ${ex.frequency}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            ex.description,
            style: const TextStyle(fontSize: 13),
          ),
          if (ex.caution != null && ex.caution!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    ex.caution!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
