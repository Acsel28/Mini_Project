import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../utils/language_utils.dart';

// User state notifier
class UserNotifier extends StateNotifier<User?> {
  UserNotifier() : super(null) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await StorageService.getUser();
    state = user;
  }

  Future<void> setUser(User user) async {
    state = user;
    await StorageService.saveUser(user);
    await StorageService.saveLanguage(user.language);
    await StorageService.setFirstTime(false);
  }

  Future<void> updateUser(User user) async {
    state = user;
    await StorageService.saveUser(user);
    await StorageService.saveLanguage(user.language);
  }

  Future<void> clearUser() async {
    state = null;
    await StorageService.clearUser();
  }

  Future<void> updateLanguage(String language) async {
    final current = state;
    if (current == null) return;
    final normalized = normalizeLanguage(language);
    final updated = current.copyWith(language: normalized);
    state = updated;
    await StorageService.saveUser(updated);
    await StorageService.saveLanguage(normalized);
  }
}

// Providers
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
