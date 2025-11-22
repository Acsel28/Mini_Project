import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../core/design_system.dart';

class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? const [Color(0xFF071524), Color(0xFF102437)]
        : const [Color(0xFFF5FFFB), Color(0xFFEAF2FF)];
    final overlayColor = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.25);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -30,
            child: _glowCircle(220, AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.32)),
          ),
          Positioned(
            top: 140,
            right: -40,
            child: _glowCircle(260, AppColors.secondary.withValues(alpha: isDark ? 0.18 : 0.28)),
          ),
          Positioned(
            bottom: -90,
            left: 120,
            child: _glowCircle(200, AppColors.accent4.withValues(alpha: isDark ? 0.14 : 0.22)),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: AppBlur.medium, sigmaY: AppBlur.medium),
              child: Container(color: overlayColor),
            ),
          ),
          child,
        ],
      ),
    );
  }

  Widget _glowCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.02)],
          stops: const [0.08, 1],
        ),
      ),
    );
  }
}
