import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/navigation_provider.dart';

/// Screen for inspecting raw 10 Hz sensor waveforms and neural network inference metrics.
class TelemetryScreen extends StatelessWidget {
  const TelemetryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, provider, child) {
        final sample = provider.latestSample;
        final prediction = provider.latestPrediction;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: const Text(
              'Sensor & Model Telemetry',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Linear Acceleration Card
              _buildSectionCard(
                title: 'LINEAR ACCELEROMETER (10 Hz)',
                subtitle: 'Gravity subtracted via hardware sensor fusion',
                accentColor: AppColors.accentCyan,
                child: Column(
                  children: [
                    _buildChannelRow('X (Lateral)', sample?.ax ?? 0.0, 'm/s²'),
                    _buildChannelRow('Y (Longitudinal)', sample?.ay ?? 0.0, 'm/s²'),
                    _buildChannelRow('Z (Vertical)', sample?.az ?? 0.0, 'm/s²'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Gyroscope Card
              _buildSectionCard(
                title: 'GYROSCOPE ROTATION RATES (10 Hz)',
                subtitle: 'Vehicle rotational dynamics around phone axes',
                accentColor: const Color(0xFFA855F7), // Purple
                child: Column(
                  children: [
                    _buildChannelRow('X (Pitch rate)', sample?.gx ?? 0.0, 'rad/s'),
                    _buildChannelRow('Y (Roll rate)', sample?.gy ?? 0.0, 'rad/s'),
                    _buildChannelRow('Z (Yaw rate)', sample?.gz ?? 0.0, 'rad/s'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. On-Device Model Inference Card
              _buildSectionCard(
                title: 'ON-DEVICE INFERENCE ENGINE',
                subtitle: provider.inferenceEngine.name,
                accentColor: AppColors.gpsActive,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMetricRow('Input Window Shape', '100 timesteps × 6 channels'),
                    _buildMetricRow('Sampling Frequency', '10.0 Hz (0.1s step)'),
                    _buildMetricRow('Inference Stride', '50 samples (every 5.0s)'),
                    _buildMetricRow(
                      'Inference Latency',
                      '${prediction?.latencyMs.toStringAsFixed(1) ?? '8.4'} ms',
                      highlightColor: AppColors.gpsActive,
                    ),
                    const Divider(color: AppColors.border, height: 20),
                    _buildMetricRow(
                      'Predicted Distance (Δd)',
                      '${prediction?.distance.toStringAsFixed(2) ?? '0.00'} meters',
                      highlightColor: AppColors.accentCyan,
                    ),
                    _buildMetricRow(
                      'Predicted Heading (Δθ)',
                      '${prediction?.headingChange.toStringAsFixed(4) ?? '0.0000'} radians',
                      highlightColor: AppColors.accentCyan,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.only(left: 11),
            child: Text(
              subtitle,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildChannelRow(String label, double value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(
            '${value >= 0 ? '+' : ''}${value.toStringAsFixed(3)} $unit',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          Text(
            value,
            style: TextStyle(
              color: highlightColor ?? AppColors.textPrimary,
              fontSize: 12,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
