import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Smoothly blends the dead-reckoned position estimate back to real GPS fixes
/// over a multi-second window upon signal restoration, preventing visual teleportation.
class FusionBlender {
  /// Total duration of the blend transition in seconds.
  final double blendDurationSeconds;

  DateTime? _blendStartTime;
  LatLng? _startDrPosition;
  bool _isBlending = false;

  FusionBlender({this.blendDurationSeconds = 3.0});

  bool get isBlending => _isBlending;

  /// Initiates a smooth blend transition from [deadReckonedPosition] to GPS.
  void startBlend(LatLng deadReckonedPosition) {
    _startDrPosition = deadReckonedPosition;
    _blendStartTime = DateTime.now();
    _isBlending = true;
  }

  /// Evaluates the blended position at the current moment given [authoritativeGps].
  ///
  /// Returns the blended coordinate, or [authoritativeGps] once the blend completes.
  LatLng update(LatLng authoritativeGps) {
    if (!_isBlending || _blendStartTime == null || _startDrPosition == null) {
      return authoritativeGps;
    }

    final elapsed = DateTime.now().difference(_blendStartTime!).inMilliseconds / 1000.0;
    final progress = (elapsed / blendDurationSeconds).clamp(0.0, 1.0);

    // Smooth cubic ease-in-out easing curve: S(t) = 3t^2 - 2t^3
    final eased = progress * progress * (3.0 - 2.0 * progress);

    if (progress >= 1.0) {
      _isBlending = false;
      _startDrPosition = null;
      _blendStartTime = null;
      return authoritativeGps;
    }

    // Geodesic / linear latitude & longitude interpolation
    final lat = _startDrPosition!.latitude +
        (_authoritative(authoritativeGps.latitude) - _startDrPosition!.latitude) * eased;
    final lon = _startDrPosition!.longitude +
        (authoritativeGps.longitude - _startDrPosition!.longitude) * eased;

    return LatLng(lat, lon);
  }

  double _authoritative(double lat) => lat;

  void cancel() {
    _isBlending = false;
    _startDrPosition = null;
    _blendStartTime = null;
  }
}
