import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'ambient_background.dart';

/// Shared shell that wraps screens inside the ambient gradient background
/// and a lightweight glass-style AppBar. Keeps every page feeling cohesive.
class WellnessScaffold extends StatelessWidget {
  const WellnessScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.padding,
    this.implyLeading = true,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final bool implyLeading;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 12);

    return AmbientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          automaticallyImplyLeading: implyLeading,
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          actions: actions,
          bottom: bottom,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ],
          ),
        ),
        floatingActionButton: floatingActionButton,
        body: SafeArea(
          child: Padding(
            padding: effectivePadding,
            child: body,
          ),
        ),
      ),
    );
  }
}
