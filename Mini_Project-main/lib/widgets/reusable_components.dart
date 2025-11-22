import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'app_styles_extended.dart';

/// Lightweight animated indicator to replace deprecated Radio widgets.
class WellnessChoiceIndicator extends StatelessWidget {
  const WellnessChoiceIndicator({
    super.key,
    required this.selected,
    this.color = AppColors.primary,
  });

  final bool selected;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final inactiveColor = AppColors.textSecondary.withValues(alpha: 0.35);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: selected ? color : inactiveColor, width: 2),
        color: selected ? color.withValues(alpha: 0.15) : Colors.transparent,
      ),
      child: selected
          ? Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// Reusable stats card showing a metric
class StatsCard extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const StatsCard({
    Key? key,
    required this.label,
    required this.value,
    this.unit,
    this.color,
    this.icon,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: PaddingValues.lg,
        decoration: AppStylesExtended.containerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (icon != null)
                  Icon(icon, size: 20, color: cardColor),
              ],
            ),
            AppStylesExtended.gapMd,
            if (isLoading)
              const SizedBox(
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: cardColor,
                    ),
                  ),
                  if (unit != null) ...[
                    AppStylesExtended.gapHSm,
                    Text(
                      unit!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

/// Section header with optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool showDivider;

  const SectionHeader({
    Key? key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.showDivider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (actionText != null)
              GestureDetector(
                onTap: onActionTap,
                child: Text(
                  actionText!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        if (showDivider) ...[
          AppStylesExtended.gapMd,
          AppStylesExtended.lightDivider,
        ],
      ],
    );
  }
}

/// Disease tag/chip component
class DiseaseTag extends StatelessWidget {
  final String name;
  final Color? color;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const DiseaseTag({
    Key? key,
    required this.name,
    this.color,
    this.onTap,
    this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: AppStylesExtended.chipDecoration(
          color: tagColor,
          borderColor: tagColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: tagColor,
              ),
            ),
            if (onRemove != null) ...[
              AppStylesExtended.gapHSm,
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 16, color: tagColor),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Nutrition macro display
class MacroDisplay extends StatelessWidget {
  final String label;
  final double value;
  final double target;
  final Color color;

  const MacroDisplay({
    Key? key,
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = (value / target).clamp(0.0, 1.0);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)}/${target.toStringAsFixed(0)}g',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppStylesExtended.radiusSm),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

/// Health metric card with trend
class HealthMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final double? trendValue; // positive or negative
  final VoidCallback? onTap;

  const HealthMetricCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trendValue,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trendColor = trendValue == null
        ? Colors.grey
        : trendValue! > 0
            ? AppColors.success
            : AppColors.error;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: PaddingValues.lg,
        decoration: AppStylesExtended.containerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AppStylesExtended.gapSm,
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            value,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (unit != null) ...[
                            AppStylesExtended.gapHSm,
                            Text(
                              unit!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (icon != null)
                  Icon(icon, size: 40, color: iconColor ?? AppColors.primary),
              ],
            ),
            if (subtitle != null || trendValue != null) ...[
              AppStylesExtended.gapMd,
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (trendValue != null)
                Row(
                  children: [
                    Icon(
                      trendValue! > 0 ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trendColor,
                    ),
                    AppStylesExtended.gapHSm,
                    Text(
                      '${trendValue!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        color: trendColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Feature card with icon and description
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const FeatureCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: PaddingValues.lg,
        decoration: AppStylesExtended.containerDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor.light,
                borderRadius: BorderRadius.circular(AppStylesExtended.radiusMd),
              ),
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? bgColor,
              ),
            ),
            AppStylesExtended.gapMd,
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppStylesExtended.gapSm,
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state placeholder
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.buttonText,
    this.onButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
          AppStylesExtended.gapXxl,
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          AppStylesExtended.gapMd,
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          if (buttonText != null) ...[
            AppStylesExtended.gapXxl,
            ElevatedButton(
              onPressed: onButtonTap,
              child: Text(buttonText!),
            ),
          ],
        ],
      ),
    );
  }
}
