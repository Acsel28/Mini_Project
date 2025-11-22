import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

class ProgressCircle extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final List<Color>? gradientColors;
  final Widget? child;

  const ProgressCircle({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor = Colors.grey,
    this.progressColor = AppColors.primary,
    this.gradientColors,
    this.child,
  });

  @override
  State<ProgressCircle> createState() => _ProgressCircleState();
}

class _ProgressCircleState extends State<ProgressCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(covariant ProgressCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      final currentValue = _animation.value;
      _animation = Tween<double>(
        begin: currentValue,
        end: widget.progress.clamp(0.0, 1.0),
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ));

      _animationController
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: 1.0,
                  strokeWidth: widget.strokeWidth,
                  color: widget.backgroundColor.withValues(alpha: 0.16),
                ),
              ),

              // Progress circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: widget.progressColor,
                  gradientColors: widget.gradientColors,
                ),
              ),

              // Center content
              if (widget.child != null)
                Center(child: widget.child!),
            ],
          ),
        );
      },
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final List<Color>? gradientColors;

  _CirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (gradientColors != null && gradientColors!.length >= 2) {
      paint.shader = SweepGradient(
        colors: gradientColors!,
        startAngle: -math.pi / 2,
        endAngle: 1.5 * math.pi,
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.strokeWidth != strokeWidth ||
           oldDelegate.color != color;
  }
}
