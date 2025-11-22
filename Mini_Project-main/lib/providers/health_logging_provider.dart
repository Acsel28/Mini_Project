import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_logging_service.dart';

// State for daily health metrics
class HealthMetrics {
  final int waterLogged; // ml
  final double sleepLogged; // hours
  final int waterGoal; // ml
  final double sleepGoal; // hours
  final List<Map<String, dynamic>> waterLogs;
  final List<Map<String, dynamic>> sleepLogs;
  final bool isLoading;
  final String? error;

  HealthMetrics({
    this.waterLogged = 0,
    this.sleepLogged = 0,
    this.waterGoal = 3000,
    this.sleepGoal = 8,
    this.waterLogs = const [],
    this.sleepLogs = const [],
    this.isLoading = false,
    this.error,
  });

  // Water percentage (0-100)
  double get waterPercentage {
    if (waterGoal == 0) return 0;
    return (waterLogged / waterGoal * 100).clamp(0, 100).toDouble();
  }

  // Sleep percentage (0-100)
  double get sleepPercentage {
    if (sleepGoal == 0) return 0;
    return (sleepLogged / sleepGoal * 100).clamp(0, 100).toDouble();
  }

  HealthMetrics copyWith({
    int? waterLogged,
    double? sleepLogged,
    int? waterGoal,
    double? sleepGoal,
    List<Map<String, dynamic>>? waterLogs,
    List<Map<String, dynamic>>? sleepLogs,
    bool? isLoading,
    String? error,
  }) {
    return HealthMetrics(
      waterLogged: waterLogged ?? this.waterLogged,
      sleepLogged: sleepLogged ?? this.sleepLogged,
      waterGoal: waterGoal ?? this.waterGoal,
      sleepGoal: sleepGoal ?? this.sleepGoal,
      waterLogs: waterLogs ?? this.waterLogs,
      sleepLogs: sleepLogs ?? this.sleepLogs,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Health logging notifier
class HealthLoggingNotifier extends StateNotifier<HealthMetrics> {
  HealthLoggingNotifier() : super(HealthMetrics());

  // Load daily summary
  Future<void> loadDailySummary() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final hydrationData = await HealthLoggingService.getHydrationSummary();
      final sleepData = await HealthLoggingService.getSleepSummary();

        developer.log('[Provider] Hydration data: $hydrationData');
        developer.log('[Provider] Sleep data: $sleepData');

        final waterLogged = (hydrationData?['totalToday'] as num? ?? 0).toInt();
      final sleepLogged = (sleepData?['hours'] as num? ?? 0.0).toDouble();
      final waterLogs = List<Map<String, dynamic>>.from(hydrationData?['logs'] ?? []);
      final sleepLogs = sleepData != null ? [sleepData] : <Map<String, dynamic>>[];

        developer.log('[Provider] Water logged: $waterLogged, Sleep logged: $sleepLogged');
      
      state = state.copyWith(
        waterLogged: waterLogged,
        sleepLogged: sleepLogged,
        waterLogs: waterLogs,
          sleepLogs: sleepLogs,
        isLoading: false,
      );
    } catch (e) {
      developer.log('Error loading daily summary: $e');
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // Log water
  Future<bool> logWater(int amountMl) async {
    try {
      final success = await HealthLoggingService.logWater(amountMl);
      if (success) {
        // Update local state
        state = state.copyWith(
          waterLogged: state.waterLogged + amountMl,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Log sleep
  Future<bool> logSleep(double hours, {String quality = 'good'}) async {
    try {
      final success = await HealthLoggingService.logSleep(hours, quality: quality);
      if (success) {
        // Update local state
        state = state.copyWith(
          sleepLogged: state.sleepLogged + hours,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final healthLoggingProvider = StateNotifierProvider<HealthLoggingNotifier, HealthMetrics>(
  (ref) => HealthLoggingNotifier(),
);
