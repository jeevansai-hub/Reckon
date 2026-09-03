import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Floating trigger button for judges and demonstrators to simulate a tunnel GPS loss.
class OutageSimulatorButton extends StatelessWidget {
  final bool isOutageActive;
  final VoidCallback onTrigger;
  final VoidCallback onCancel;

  const OutageSimulatorButton({
    super.key,
    required this.isOutageActive,
    required this.onTrigger,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isOutageActive ? onCancel : onTrigger,
      icon: Icon(
        isOutageActive ? Icons.satellite_alt : Icons.sensors_off,
        size: 18,
        color: Colors.white,
      ),
      label: Text(
        isOutageActive ? 'Restore GPS Signal' : 'Simulate Tunnel Outage',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutageActive ? AppColors.reacquisition : AppColors.deadReckoning,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 8,
        shadowColor: isOutageActive ? AppColors.reacquisitionGlow : AppColors.deadReckoningGlow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: Colors.white.withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
    );
  }
}
