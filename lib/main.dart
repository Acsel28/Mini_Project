import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'core/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/home/main_navigation_screen.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';

// new import - auth provider to be used by SplashScreen etc.
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await StorageService.init();
  await TTSService.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

TextStyle safePoppins(double size, {FontWeight weight = FontWeight.normal, Color? color}) {
  return TextStyle(
    fontFamily: 'sans-serif', // uses system font
    fontSize: size,
    fontWeight: weight,
    color: color,
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'AI Diet App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      // keep SplashScreen as the landing page — it will choose where to go next
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        //'/register': (context) => const RegisterScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}
