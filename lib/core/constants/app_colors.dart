import 'package:flutter/material.dart';

/// Automotive dark-mode theme colors for the Reckon Companion App.
/// Designed for high glanceability and contrast while driving at night.
class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceGlass = Color(0xD9131B2E);
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color border = Color(0xFF334155);

  // Status & Mode Colors
  static const Color gpsActive = Color(0xFF10B981);       // Emerald Green
  static const Color gpsActiveGlow = Color(0x4010B981);
  static const Color deadReckoning = Color(0xFFF59E0B);    // Amber
  static const Color deadReckoningGlow = Color(0x40F59E0B);
  static const Color reacquisition = Color(0xFF3B82F6);    // Dodger Blue
  static const Color reacquisitionGlow = Color(0x403B82F6);

  // Brand Accents
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentCyanGlow = Color(0x3306B6D4);

  // Benchmark Polyline Colors
  static const Color pathGpsTrue = Color(0xFF10B981);      // Green
  static const Color pathReckonAi = Color(0xFF06B6D4);     // Cyan
  static const Color pathNaiveDrift = Color(0xFFF43F5E);   // Rose / Red

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
}
