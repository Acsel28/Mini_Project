import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../core/constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  // Initialize storage service
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User data storage
  static Future<void> saveUser(User user) async {
    await _prefs?.setString(AppConstants.userDataKey, user.toJson());
  }

  static Future<User?> getUser() async {
    final userJson = _prefs?.getString(AppConstants.userDataKey);
    if (userJson != null) {
      return User.fromJson(userJson);
    }
    return null;
  }

  static Future<void> clearUser() async {
    await _prefs?.remove(AppConstants.userDataKey);
  }

  // App settings
  static Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs?.setBool(AppConstants.isFirstTimeKey, isFirstTime);
  }

  static Future<bool> isFirstTime() async {
    return _prefs?.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  // Language preference
  static Future<void> saveLanguage(String language) async {
    await _prefs?.setString(AppConstants.languageKey, language);
  }

  static Future<String> getLanguage() async {
    return _prefs?.getString(AppConstants.languageKey) ?? 'english';
  }

  // Accessibility mode
  static Future<void> setAccessibilityMode(bool enabled) async {
    await _prefs?.setBool(AppConstants.accessibilityModeKey, enabled);
  }

  static Future<bool> getAccessibilityMode() async {
    return _prefs?.getBool(AppConstants.accessibilityModeKey) ?? false;
  }

  // Clear all data
  static Future<void> clearAllData() async {
    await _prefs?.clear();
  }
}
