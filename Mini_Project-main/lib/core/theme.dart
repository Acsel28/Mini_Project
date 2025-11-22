import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_system.dart';

class AppColors {
  static const Color primary = Color(0xFF33C5A0);
  static const Color primaryDark = Color(0xFF1E7F73);
  static const Color primaryLight = Color(0xFFC6F4E7);

  static const Color secondary = Color(0xFFFFA861);
  static const Color tertiary = Color(0xFF6C7CFF);

  static const Color accent1 = Color(0xFF65D5B5);
  static const Color accent2 = Color(0xFFFFD27C);
  static const Color accent3 = Color(0xFFB2A0FF);
  static const Color accent4 = Color(0xFF2FB4D4);

  static const Color background = Color(0xFFF6F8FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFECF4F1);
  static const Color surfaceMuted = Color(0xFFE4EBF7);

  static const Color textPrimary = Color(0xFF0F1C2D);
  static const Color textSecondary = Color(0xFF2C3B4F);
  static const Color textTertiary = Color(0xFF5E6E86);

  static const Color success = Color(0xFF21B573);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFEB5757);
  static const Color info = Color(0xFF3478F6);

  static const Color protein = Color(0xFF7C3AED);
  static const Color carbs = Color(0xFF2563EB);
  static const Color fat = Color(0xFFF97316);
}

class AppGradients {
  static const Gradient hero = LinearGradient(
    colors: [Color(0xFF3EDEB4), Color(0xFF49A7FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glass = LinearGradient(
    colors: [Color(0xB3FFFFFF), Color(0x66F5FBFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient sunrise = LinearGradient(
    colors: [Color(0xFFFFC3A0), Color(0xFFFF8DA1)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x1A0E1842),
      blurRadius: 28,
      offset: Offset(0, 16),
    ),
  ];
}

class AppTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    final colorScheme = baseScheme.copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryLight,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.surfaceAlt,
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.accent3,
      error: AppColors.error,
      onError: Colors.white,
      errorContainer: AppColors.warning,
      onErrorContainer: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      surfaceBright: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceAlt,
      surfaceContainerHigh: AppColors.surfaceAlt,
      surfaceContainer: AppColors.surfaceMuted,
      surfaceContainerLow: AppColors.surfaceMuted,
      outline: AppColors.textTertiary,
      outlineVariant: AppColors.surfaceAlt,
      shadow: const Color(0x1A0F172A),
      scrim: Colors.black54,
      inverseSurface: AppColors.textPrimary,
      inversePrimary: AppColors.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w700,
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        prefixIconColor: AppColors.primaryDark,
        suffixIconColor: AppColors.primaryDark,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.error.withValues(alpha: 0.85), width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          overlayColor: AppColors.primary.withValues(alpha: 0.08),
          side: const BorderSide(color: AppColors.primary, width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor: AppColors.primary.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.pill,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.surfaceAlt,
        thickness: 1,
        space: 32,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textTertiary,
        showUnselectedLabels: false,
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    final light = lightTheme;
    final darkScheme = light.colorScheme.copyWith(
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: AppColors.primaryDark,
      surface: const Color(0xFF1F2937),
      onSurface: Colors.white,
      surfaceBright: const Color(0xFF1F2937),
      surfaceContainerHighest: const Color(0xFF1F2A37),
      surfaceContainerLow: const Color(0xFF111827),
      scrim: Colors.black,
    );

    return light.copyWith(
      brightness: Brightness.dark,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      appBarTheme: light.appBarTheme.copyWith(
        foregroundColor: Colors.white,
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: light.cardTheme.copyWith(color: const Color(0xFF273549)),
      inputDecorationTheme: light.inputDecorationTheme.copyWith(
        fillColor: const Color(0xFF1F2A37),
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      ),
      bottomNavigationBarTheme: light.bottomNavigationBarTheme.copyWith(
        backgroundColor: const Color(0xFF1F2A37),
        selectedItemColor: AppColors.primaryLight,
      ),
    );
  }
}

class AppStyles {
  static BoxDecoration cardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFFFFFFF), Color(0xFFF4FBFF)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: AppRadius.lg,
    boxShadow: const [
      BoxShadow(
        color: Color(0x1A1D3557),
        blurRadius: 40,
        offset: Offset(0, 22),
      ),
    ],
    border: Border.all(color: AppColors.surfaceAlt.withValues(alpha: 0.9)),
  );

  static BoxDecoration gradientDecoration = const BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0EBE99), Color(0xFF2EA0F3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.all(Radius.circular(28)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x33249D8F),
        blurRadius: 35,
        offset: Offset(0, 18),
      ),
    ],
  );

  static BoxDecoration glassDecoration = BoxDecoration(
    gradient: AppGradients.glass,
    borderRadius: BorderRadius.circular(30),
    border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
    boxShadow: const [
      BoxShadow(
        color: Color(0x1AFFFFFF),
        blurRadius: 20,
        offset: Offset(0, 12),
      )
    ],
  );
}
