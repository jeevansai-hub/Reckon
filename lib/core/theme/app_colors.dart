import 'package:flutter/material.dart';

/// Reckon's dark HUD/navigation palette.
///
/// Three position-source states drive the accent used across the app:
/// GPS (cyan, "locked"), sensor-only dead-reckoning (amber, "estimating"),
/// and fusion/reacquisition (magenta, "blending"). Keeping these three
/// consistent everywhere is what lets a judge glance at the screen and
/// instantly read the current mode.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF06090F);
  static const Color surface = Color(0xFF0D1420);
  static const Color surfaceRaised = Color(0xFF141E2E);
  static const Color hairline = Color(0xFF223046);

  static const Color textPrimary = Color(0xFFEAF2FF);
  static const Color textSecondary = Color(0xFF8CA0BC);
  static const Color textMuted = Color(0xFF52657F);

  static const Color gps = Color(0xFF35E2C8);
  static const Color gpsGlow = Color(0x5535E2C8);

  static const Color sensorOnly = Color(0xFFFFB648);
  static const Color sensorOnlyGlow = Color(0x55FFB648);

  static const Color fusion = Color(0xFFFF4FD8);
  static const Color fusionGlow = Color(0x55FF4FD8);

  static const Color danger = Color(0xFFFF5B5B);

  static Color modeColor(String mode) {
    switch (mode) {
      case 'sensorOnly':
        return sensorOnly;
      case 'fusion':
        return fusion;
      default:
        return gps;
    }
  }

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1220), Color(0xFF06090F)],
  );
}
