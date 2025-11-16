import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../services/exercise_service.dart';

class ExerciseScreen extends ConsumerStatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ConsumerState<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends ConsumerState<ExerciseScreen> {
  bool _loading = false;
  String? _error;
  List<dynamic> _exercises = [];
  String? _mode;
  String? _condition;
  final TextEditingController _conditionCtrl = TextEditingController();
  final TextEditingController _customCtrl = TextEditingController();

  Future<void> _loadPlan() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await ExerciseService.getExercisePlan(
        condition: _conditionCtrl.text.trim().isEmpty
            ? null
            : _conditionCtrl.text.trim(),
        customCondition: _customCtrl.text.trim().isEmpty
            ? null
            : _customCtrl.text.trim(),
      );

      setState(() {
        _mode = res['mode']?.toString();
        _condition = res['condition']?.toString();
        _exercises = (res['exercises'] as List?) ?? [];
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _conditionCtrl.dispose();
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise Plan')),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Disease / Condition (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _conditionCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. knee_pain, diabetes, pcos',
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Custom description (optional)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _customCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g. pain when climbing stairs',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _loadPlan,
                child: _loading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Generate Exercise Plan'),
              ),
            ),
            const SizedBox(height: 8),
            if (_mode != null)
              Text(
                'Source: ${_mode == 'llm' ? 'AI-generated' : 'Static fallback'} (${_condition ?? 'general'})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(
                      child: Text('No exercises loaded yet'),
                    )
                  : ListView.separated(
                      itemCount: _exercises.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ex = _exercises[index] as Map<String, dynamic>;
                        return _buildExerciseCard(ex);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> ex) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppStyles.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ex['name']?.toString() ?? 'Exercise',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (ex['target_area'] != null || ex['intensity'] != null) ...[
            const SizedBox(height: 4),
            Text(
              [
                if (ex['target_area'] != null) ex['target_area'].toString(),
                if (ex['intensity'] != null) 'Intensity: ${ex['intensity']}',
              ].where((e) => e.isNotEmpty).join(' • '),
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const SizedBox(height: 6),
          if (ex['duration'] != null || ex['sets'] != null || ex['reps_or_duration'] != null)
            Text(
              [
                if (ex['duration'] != null) 'Duration: ${ex['duration']}',
                if (ex['sets'] != null) 'Sets: ${ex['sets']}',
                if (ex['reps_or_duration'] != null)
                  ex['reps_or_duration'].toString(),
              ].where((e) => e.isNotEmpty).join(' • '),
              style: const TextStyle(fontSize: 12),
            ),
          if (ex['frequency'] != null || ex['frequency_per_week'] != null) ...[
            const SizedBox(height: 4),
            Text(
              'Frequency: ${(ex['frequency'] ?? ex['frequency_per_week']).toString()}',
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (ex['description'] != null) ...[
            const SizedBox(height: 6),
            Text(
              ex['description'].toString(),
              style: const TextStyle(fontSize: 12),
            ),
          ],
          if (ex['caution'] != null || ex['cautions'] != null) ...[
            const SizedBox(height: 6),
            Text(
              'Caution: ${(ex['caution'] ?? ex['cautions']).toString()}',
              style: const TextStyle(fontSize: 12, color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}
