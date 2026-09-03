import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A translucent, blurred HUD-style panel used throughout the app for
/// anything floating over the map (mode chip, outage sheet, trip cards).
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? AppColors.hairline),
          ),
          child: child,
        ),
      ),
    );
  }
}
