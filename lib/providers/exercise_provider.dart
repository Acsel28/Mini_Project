import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise_model.dart';
import '../services/exercise_service.dart';

class ExerciseNotifier extends StateNotifier<AsyncValue<List<Exercise>>> {
  ExerciseNotifier() : super(const AsyncValue.loading()) {
    loadGeneralExercises();
  }

  Future<void> loadGeneralExercises() async {
    state = const AsyncValue.loading();
    try {
      final exercises = await ExerciseService.getExercises();
      state = AsyncValue.data(exercises);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadForCondition(String condition) async {
    state = const AsyncValue.loading();
    try {
      final exercises =
          await ExerciseService.getExercises(condition: condition);
      state = AsyncValue.data(exercises);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, AsyncValue<List<Exercise>>>(
  (ref) => ExerciseNotifier(),
);
