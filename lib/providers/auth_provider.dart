// lib/providers/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, '
        'isAuthenticated: $isAuthenticated, '
        'error: $error)';
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  /// Used if you ever want to register via provider (not required for onboarding).
  Future<void> register(String email, String password, {String? name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.register(email, password, name: name);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  /// Login called from LoginScreen.
  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        error: e.toString(),
      );
    }
  }

  /// Optional: if you want to auto-login using stored token + /me later.
  Future<void> loadCurrentUser() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await AuthService.getMe(); // we don't use the response yet, just test token
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        error: null,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);
