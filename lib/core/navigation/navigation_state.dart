import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The tri-mode operational status of the vehicle positioning system.
enum NavigationMode {
  /// Mode 1: High-confidence GPS satellite fix available (Pass-Through).
  gpsActive,

  /// Mode 2: GPS unavailable/degraded (Tunnel, Underground, Jammed).
  /// Position continuously updated via on-device LSTM Inertial Odometry.
  deadReckoning,

  /// Mode 3: GPS restored after an outage.
  /// Smoothly blends the dead-reckoned estimate back to true GPS without jumping.
  reacquisition,
}

extension NavigationModeDetails on NavigationMode {
  String get label {
    switch (this) {
      case NavigationMode.gpsActive:
        return 'GPS FIXED';
      case NavigationMode.deadReckoning:
        return 'DEAD RECKONING (LSTM)';
      case NavigationMode.reacquisition:
        return 'REACQUIRING & BLENDING';
    }
  }

  String get description {
    switch (this) {
      case NavigationMode.gpsActive:
        return 'Satellite position stream active';
      case NavigationMode.deadReckoning:
        return 'Tracking vehicle via smartphone motion sensors';
      case NavigationMode.reacquisition:
        return 'Smoothly resynchronizing position to GPS fix';
    }
  }

  Color get color {
    switch (this) {
      case NavigationMode.gpsActive:
        return AppColors.gpsActive;
      case NavigationMode.deadReckoning:
        return AppColors.deadReckoning;
      case NavigationMode.reacquisition:
        return AppColors.reacquisition;
    }
  }

  Color get glowColor {
    switch (this) {
      case NavigationMode.gpsActive:
        return AppColors.gpsActiveGlow;
      case NavigationMode.deadReckoning:
        return AppColors.deadReckoningGlow;
      case NavigationMode.reacquisition:
        return AppColors.reacquisitionGlow;
    }
  }
}
