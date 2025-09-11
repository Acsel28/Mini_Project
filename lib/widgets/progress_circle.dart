import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressCircle extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;
  final Widget? child;

  const ProgressCircle({
    super.key,
    required this.progress,
    this.size = 100,
    this.strokeWidth = 8,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
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
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
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
                  color: widget.backgroundColor.withOpacity(0.3),
                ),
              ),

              // Progress circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _CirclePainter(
                  progress: _animation.value,
                  strokeWidth: widget.strokeWidth,
                  color: widget.progressColor,
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

  _CirclePainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
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
