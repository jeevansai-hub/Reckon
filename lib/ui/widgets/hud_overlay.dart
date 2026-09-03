import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/navigation/navigation_state.dart';

/// The bottom automotive cockpit HUD overlay.
class HudOverlay extends StatelessWidget {
  final double speedKmh;
  final double headingDeg;
  final NavigationMode mode;
  final int outageRemainingSeconds;

  const HudOverlay({
    super.key,
    required this.speedKmh,
    required this.headingDeg,
    required this.mode,
    required this.outageRemainingSeconds,
  });

  String _headingToCardinal(double deg) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final idx = ((deg + 22.5) % 360 / 45).floor();
    return directions[idx];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.border.withOpacity(0.4)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTelemetryItem(
                label: 'SPEED',
                value: speedKmh.toStringAsFixed(0),
                unit: 'km/h',
                valueColor: AppColors.textPrimary,
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              _buildTelemetryItem(
                label: 'HEADING',
                value: '${headingDeg.toStringAsFixed(0)}°',
                unit: _headingToCardinal(headingDeg),
                valueColor: AppColors.accentCyan,
              ),
              Container(width: 1, height: 36, color: AppColors.border),
              _buildTelemetryItem(
                label: 'IMU RATE',
                value: '10',
                unit: 'Hz',
                valueColor: AppColors.gpsActive,
              ),
            ],
          ),
          if (mode == NavigationMode.deadReckoning) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GPS OUTAGE SIMULATION ACTIVE',
                  style: TextStyle(
                    color: AppColors.deadReckoning,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${outageRemainingSeconds}s remaining',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: outageRemainingSeconds / 15.0,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.deadReckoning),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryItem({
    required String label,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const TextSpan(text: ' '),
              TextSpan(
                text: unit,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
