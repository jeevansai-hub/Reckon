import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../providers/navigation_provider.dart';

/// Judge-facing outage demo (Project-Context §5.3): lets a demo run trigger
/// a simulated GPS outage on demand, without physically driving into a tunnel.
class OutageControlSheet extends StatefulWidget {
  const OutageControlSheet({super.key});

  @override
  State<OutageControlSheet> createState() => _OutageControlSheetState();
}

class _OutageControlSheetState extends State<OutageControlSheet> {
  double _seconds = 12;

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: GlassPanel(
        borderRadius: 28,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.satellite_alt_rounded, color: AppColors.sensorOnly),
                const SizedBox(width: 10),
                Text('Simulate GPS outage', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Forces sensor-only mode for the phone, then blends back to GPS — '
              'demo the tunnel scenario without driving into one.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text('Duration', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                Text(
                  '${_seconds.round()}s',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.sensorOnly),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.sensorOnly,
                thumbColor: AppColors.sensorOnly,
                inactiveTrackColor: AppColors.hairline,
              ),
              child: Slider(
                value: _seconds,
                min: 5,
                max: 30,
                divisions: 25,
                onChanged: (v) => setState(() => _seconds = v),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: nav.outageActive
                    ? null
                    : () {
                        nav.triggerOutage(durationSeconds: _seconds.round());
                        Navigator.of(context).pop();
                      },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.sensorOnly),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(nav.outageActive ? 'Outage in progress…' : 'Trigger outage'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
