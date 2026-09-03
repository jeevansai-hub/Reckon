import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/navigation_state.dart';

/// A prominent status pill displaying the active vehicle positioning mode.
class StatusPill extends StatelessWidget {
  final NavigationMode mode;
  final VoidCallback? onTap;

  const StatusPill({
    super.key,
    required this.mode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceGlass,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: mode.color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: mode.glowColor,
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mode.color,
                boxShadow: [
                  BoxShadow(
                    color: mode.color,
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              mode.label,
              style: TextStyle(
                color: mode.color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
