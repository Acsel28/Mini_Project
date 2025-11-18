import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/disease_model.dart';
import '../services/disease_service.dart';

// Disease list provider
final diseaseListProvider = FutureProvider<List<Disease>>((ref) async {
  final result = await DiseaseService.getAllDiseases();
  if (result == null) return [];
  return result.map((e) => Disease.fromJson(e as Map<String, dynamic>)).toList();
});

// Disease search provider
final diseaseSearchProvider = FutureProvider.family<List<Disease>, String>((ref, query) async {
  if (query.isEmpty) {
    return ref.watch(diseaseListProvider).whenData((diseases) => diseases).value ?? [];
  }
  final result = await DiseaseService.searchDiseases(query);
  if (result == null) return [];
  return result.map((e) => Disease.fromJson(e as Map<String, dynamic>)).toList();
});

// Full disease profile provider
final fullDiseaseProfileProvider =
    FutureProvider.family<FullDiseaseProfile?, String>((ref, diseaseKey) async {
  final result = await DiseaseService.getFullDiseaseProfile(diseaseKey);
  if (result == null) return null;
  return FullDiseaseProfile.fromJson(result);
});

// Disease details provider
final diseaseDetailsProvider =
    FutureProvider.family<DiseaseDetailsResponse?, String>((ref, diseaseKey) async {
  final result = await DiseaseService.getDetailedDiseaseInfo(diseaseKey);
  if (result == null) return null;
  return DiseaseDetailsResponse.fromJson(result);
});

// Disease diet info provider
final diseaseDietProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, diseaseKey) async {
  return await DiseaseService.getDietForDisease(diseaseKey);
});

// Disease exercises provider
final diseaseExercisesProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, diseaseKey) async {
  return await DiseaseService.getExercisesForDisease(diseaseKey);
});

// User's selected diseases provider (if they have health conditions)
final selectedDiseasesProvider =
    StateNotifierProvider<SelectedDiseasesNotifier, List<String>>((ref) {
  return SelectedDiseasesNotifier();
});

class SelectedDiseasesNotifier extends StateNotifier<List<String>> {
  SelectedDiseasesNotifier() : super([]);

  void selectDisease(String diseaseKey) {
    if (!state.contains(diseaseKey)) {
      state = [...state, diseaseKey];
    }
  }

  void deselectDisease(String diseaseKey) {
    state = state.where((k) => k != diseaseKey).toList();
  }

  void clearSelection() {
    state = [];
  }

  void setDiseases(List<String> diseases) {
    state = diseases;
  }
}

// Provider to get combined health recommendations for selected diseases
final combinedHealthRecommendationsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final selectedDiseases = ref.watch(selectedDiseasesProvider);
  
  final recommendations = <String, dynamic>{
    'diets': <String, DietInfo>{},
    'exercises': <String, ExerciseRecommendations>{},
    'lifestyle': <String, Map<String, dynamic>>{},
  };

  for (final diseaseKey in selectedDiseases) {
    final profile = await ref.watch(fullDiseaseProfileProvider(diseaseKey).future);
    if (profile != null) {
      if (profile.diet != null) {
        recommendations['diets'][diseaseKey] = profile.diet!;
      }
      if (profile.exercise != null) {
        recommendations['exercises'][diseaseKey] = profile.exercise!;
      }
      recommendations['lifestyle'][diseaseKey] = {
        'tips': profile.lifestyle.tips,
        'monitoring': profile.lifestyle.monitoring,
      };
    }
  }

  return recommendations;
});

// Provider to get unified diet recommendations (avoiding conflicts)
final unifiedDietRecommendationsProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final selectedDiseases = ref.watch(selectedDiseasesProvider);
  
  if (selectedDiseases.isEmpty) {
    return {
      'avoidFoods': [],
      'recommendedFoods': [],
      'constraints': {},
      'conflicts': []
    };
  }

  final allDiets = <DietInfo>[];
  final allAvoidFoods = <String>{};
  final allRecommendedFoods = <String>{};
  final allConstraints = <String, dynamic>{};

  for (final diseaseKey in selectedDiseases) {
    final diet = await ref.watch(diseaseDietProvider(diseaseKey).future);
    if (diet != null && diet['diet'] != null) {
      final dietInfo = DietInfo.fromJson(diet['diet']);
      allDiets.add(dietInfo);
      allAvoidFoods.addAll(dietInfo.avoidFoods);
      allRecommendedFoods.addAll(dietInfo.recommendedFoods);
      allConstraints.addAll(dietInfo.constraints);
    }
  }

  // Check for conflicts
  final conflicts = allAvoidFoods.intersection(allRecommendedFoods).toList();

  return {
    'avoidFoods': allAvoidFoods.toList(),
    'recommendedFoods': allRecommendedFoods.toList(),
    'constraints': allConstraints,
    'conflictingFoods': conflicts,
    'diseaseCount': selectedDiseases.length,
  };
});
