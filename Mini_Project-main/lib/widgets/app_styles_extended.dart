import 'package:flutter/material.dart';
import '../core/theme.dart';

/// Extended app styles and utilities
class AppStylesExtended {
  // ========== SPACING ==========
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ========== BORDER RADIUS ==========
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusCircle = 100.0;

  // ========== SHADOWS ==========
  static const List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Color.fromARGB(26, 0, 0, 0),
      offset: Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Color.fromARGB(38, 0, 0, 0),
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Color.fromARGB(51, 0, 0, 0),
      offset: Offset(0, 4),
      blurRadius: 8),
    BoxShadow(
      color: Color.fromARGB(26, 0, 0, 0),
      offset: Offset(0, 2),
      blurRadius: 4),
  ];

  // ========== DECORATIONS ==========
  static BoxDecoration get containerDecoration {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(radiusLg),
      boxShadow: shadowMd,
    );
  }

  static BoxDecoration roundedDecoration({
    Color color = AppColors.surface,
    double radius = radiusLg,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? shadowMd,
    );
  }

  static BoxDecoration gradientDecoration({
    required List<Color> colors,
    double radius = radiusLg,
    List<BoxShadow>? shadow,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadow ?? shadowMd,
    );
  }

  static BoxDecoration chipDecoration({
    required Color color,
    required Color borderColor,
    double borderWidth = 1.5,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: 0.1),
      border: Border.all(color: borderColor, width: borderWidth),
      borderRadius: BorderRadius.circular(radiusLg),
    );
  }

  // ========== DIVIDERS ==========
  static const Divider lightDivider = Divider(
    height: 1,
    color: Color(0xFFEEEEEE),
    thickness: 1,
  );

  // ========== GAPS ==========
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);
  static const SizedBox gapXxxl = SizedBox(height: xxxl);

  static const SizedBox gapHXs = SizedBox(width: xs);
  static const SizedBox gapHSm = SizedBox(width: sm);
  static const SizedBox gapHMd = SizedBox(width: md);
  static const SizedBox gapHLg = SizedBox(width: lg);
  static const SizedBox gapHXl = SizedBox(width: xl);
  static const SizedBox gapHXxl = SizedBox(width: xxl);
  static const SizedBox gapHXxxl = SizedBox(width: xxxl);
}

/// Padding extensions
class PaddingValues {
  static const EdgeInsets none = EdgeInsets.zero;
  static const EdgeInsets xs = EdgeInsets.all(AppStylesExtended.xs);
  static const EdgeInsets sm = EdgeInsets.all(AppStylesExtended.sm);
  static const EdgeInsets md = EdgeInsets.all(AppStylesExtended.md);
  static const EdgeInsets lg = EdgeInsets.all(AppStylesExtended.lg);
  static const EdgeInsets xl = EdgeInsets.all(AppStylesExtended.xl);
  static const EdgeInsets xxl = EdgeInsets.all(AppStylesExtended.xxl);

  // Horizontal padding
  static const EdgeInsets hSm = EdgeInsets.symmetric(horizontal: AppStylesExtended.sm);
  static const EdgeInsets hMd = EdgeInsets.symmetric(horizontal: AppStylesExtended.md);
  static const EdgeInsets hLg = EdgeInsets.symmetric(horizontal: AppStylesExtended.lg);
  static const EdgeInsets hXl = EdgeInsets.symmetric(horizontal: AppStylesExtended.xl);

  // Vertical padding
  static const EdgeInsets vSm = EdgeInsets.symmetric(vertical: AppStylesExtended.sm);
  static const EdgeInsets vMd = EdgeInsets.symmetric(vertical: AppStylesExtended.md);
  static const EdgeInsets vLg = EdgeInsets.symmetric(vertical: AppStylesExtended.lg);
  static const EdgeInsets vXl = EdgeInsets.symmetric(vertical: AppStylesExtended.xl);
}

/// Color extensions
extension ColorExtensions on Color {
  Color get light => withValues(alpha: 0.1);
  Color get lighter => withValues(alpha: 0.05);
  Color get dark => withValues(alpha: 0.8);
  Color get darker => withValues(alpha: 0.95);
  Color get muted => withValues(alpha: 0.5);
  Color get disabled => withValues(alpha: 0.38);
}

/// Text style extensions
extension TextStyleExtensions on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semibold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  
  TextStyle get primary => copyWith(color: AppColors.primary);
  TextStyle get secondary => copyWith(color: AppColors.secondary);
  TextStyle get success => copyWith(color: AppColors.success);
  TextStyle get error => copyWith(color: AppColors.error);
  TextStyle get warning => copyWith(color: AppColors.warning);
  
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}

/// Widget extensions
extension PaddingExtension on Widget {
  Widget padding(EdgeInsets value) => Padding(padding: value, child: this);
  Widget paddingAll(double value) => Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical), child: this);
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) =>
      Padding(padding: EdgeInsets.only(left: left, top: top, right: right, bottom: bottom), child: this);
}
