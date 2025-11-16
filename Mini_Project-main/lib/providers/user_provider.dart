import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';

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
    await StorageService.setFirstTime(false);
  }

  Future<void> updateUser(User user) async {
    state = user;
    await StorageService.saveUser(user);
  }

  Future<void> clearUser() async {
    state = null;
    await StorageService.clearUser();
  }
}

// Providers
final userProvider = StateNotifierProvider<UserNotifier, User?>((ref) {
  return UserNotifier();
});
