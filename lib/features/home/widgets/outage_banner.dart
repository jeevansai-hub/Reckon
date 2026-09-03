import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../providers/navigation_provider.dart';

/// Live countdown shown while a simulated outage is running, so a judge
/// watching the demo can see exactly how long sensor-only mode has left
/// before Reckon blends back onto GPS.
class OutageBanner extends StatelessWidget {
  const OutageBanner({super.key, required this.secondsRemaining});

  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderColor: AppColors.sensorOnly.withValues(alpha: 0.6),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.satellite_alt_rounded, color: AppColors.sensorOnly, size: 18),
          const SizedBox(width: 10),
          Text(
            'GPS-denied · reconnecting in ${secondsRemaining}s',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.sensorOnly),
          ),
        ],
      ),
    );
  }
}

/// Wraps [child] with a mode-aware slide/fade so the outage banner appears
/// only while [mode] is sensor-only, without layout jumping when it's gone.
class OutageBannerSlot extends StatelessWidget {
  const OutageBannerSlot({super.key, required this.mode, required this.secondsRemaining});

  final PositionMode mode;
  final int secondsRemaining;

  @override
  Widget build(BuildContext context) {
    final visible = mode == PositionMode.sensorOnly;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(animation),
          child: child,
        ),
      ),
      child: visible
          ? OutageBanner(key: const ValueKey('banner'), secondsRemaining: secondsRemaining)
          : const SizedBox.shrink(key: ValueKey('empty')),
    );
  }
}
