import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/glass_panel.dart';
import '../../providers/navigation_provider.dart';

/// Stretch screen from Project-Context §5.4: after a drive, show the
/// reconstructed path so far — this is the same before/after visual the ML
/// repo's own evaluation pipeline produces (ATE/RPE against true GPS),
/// but live and on-device rather than an offline report.
class TripSummaryScreen extends StatelessWidget {
  const TripSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Trip summary')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            SizedBox(
              height: 260,
              child: ClipRRect(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: nav.position,
                    initialZoom: 14,
                    interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.reckon.app',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(points: nav.path, strokeWidth: 4, color: AppColors.gps),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Distance',
                            value: '${(nav.tripDistanceMetres / 1000).toStringAsFixed(2)} km',
                            accent: AppColors.gps,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _StatCard(
                            label: 'Path points',
                            value: '${nav.path.length}',
                            accent: AppColors.fusion,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlassPanel(
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Quantified accuracy (ATE / RPE vs. true GPS) lands once model-v1 '
                              'is exported from the ML repo — see Project-Context §10.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: () => context.read<NavigationProvider>().resetTrip(),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset trip'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.accent});
  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      borderColor: accent.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: accent)),
        ],
      ),
    );
  }
}
