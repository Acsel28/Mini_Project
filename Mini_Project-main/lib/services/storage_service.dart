// lib/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';
import '../utils/language_utils.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveUser(User user) async {
    await _prefs?.setString(AppConstants.userDataKey, user.toJson());
  }

  static Future<User?> getUser() async {
    final userJson = _prefs?.getString(AppConstants.userDataKey);
    if (userJson != null && userJson.isNotEmpty) {
      // Use the flexible fromJson that accepts String
      return User.fromJson(userJson);
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(AppConstants.userDataKey);
  }

  static Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs?.setBool(AppConstants.isFirstTimeKey, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    return _prefs?.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  static Future<void> saveLanguage(String language) async {
    await _prefs?.setString(AppConstants.languageKey, normalizeLanguage(language));
  }

  static Future<String> getLanguage() async {
    return normalizeLanguage(_prefs?.getString(AppConstants.languageKey));
  }

  static Future<void> setAccessibilityMode(bool enabled) async {
    await _prefs?.setBool(AppConstants.accessibilityModeKey, enabled);
  }

  static Future<bool> getAccessibilityMode() async {
    return _prefs?.getBool(AppConstants.accessibilityModeKey) ?? false;
  }

  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
