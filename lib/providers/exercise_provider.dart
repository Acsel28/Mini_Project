import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/exercise_service.dart';

class ExercisePlanState {
  final bool isLoading;
  final String? error;
  final List<Map<String, dynamic>> exercises;
  final String? mode;      // 'llm' or 'fallback_static'
  final String? condition; // diabetes / knee_pain / general

  ExercisePlanState({
    required this.isLoading,
    required this.exercises,
    this.error,
    this.mode,
    this.condition,
  });

  factory ExercisePlanState.initial() => ExercisePlanState(
        isLoading: false,
        exercises: const [],
        error: null,
        mode: null,
        condition: null,
      );

  ExercisePlanState copyWith({
    bool? isLoading,
    String? error,
    List<Map<String, dynamic>>? exercises,
    String? mode,
    String? condition,
  }) {
    return ExercisePlanState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      exercises: exercises ?? this.exercises,
      mode: mode ?? this.mode,
      condition: condition ?? this.condition,
    );
  }
}

class ExercisePlanNotifier extends StateNotifier<ExercisePlanState> {
  ExercisePlanNotifier() : super(ExercisePlanState.initial());

  Future<void> loadPlan({
    String? condition,
    String? customCondition,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final res = await ExerciseService.getExercisePlan(
        condition: condition,
        customCondition: customCondition,
      );

      final exercises =
          (res['exercises'] as List?)?.map<Map<String, dynamic>>(
                (e) => Map<String, dynamic>.from(e as Map),
              ).toList() ??
              <Map<String, dynamic>>[];

      state = state.copyWith(
        isLoading: false,
        exercises: exercises,
        mode: res['mode']?.toString(),
        condition: res['condition']?.toString(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clear() {
    state = ExercisePlanState.initial();
  }
}

// Riverpod provider
final exercisePlanProvider =
    StateNotifierProvider<ExercisePlanNotifier, ExercisePlanState>((ref) {
  return ExercisePlanNotifier();
});
