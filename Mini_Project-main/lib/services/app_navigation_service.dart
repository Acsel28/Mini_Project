import 'package:flutter/material.dart';

import '../screens/home/home_screen.dart';
import '../screens/home/ingredients_screen.dart';
import '../screens/home/insights_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/home/progress_screen.dart';
import '../screens/home/dynamic_health_search_screen.dart';
import '../screens/home/coach_chat_screen.dart';
import '../screens/home/nutrition_analytics_screen.dart';

class AppNavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<void> openScreen(String screenId) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    Widget builder() {
      switch (screenId) {
        case 'home':
          return const HomeScreen();
        case 'ingredients':
          return const IngredientsScreen();
        case 'insights':
          return const InsightsScreen();
        case 'profile':
          return const ProfileScreen();
        case 'progress':
          return const ProgressScreen();
        case 'search':
          return const DynamicHealthSearchScreen();
        case 'coach':
          return const CoachChatScreen();
        case 'analytics':
          return const NutritionAnalyticsScreen();
        default:
          return const HomeScreen();
      }
    }

    await navigator.push(MaterialPageRoute(builder: (_) => builder()));
  }
}
