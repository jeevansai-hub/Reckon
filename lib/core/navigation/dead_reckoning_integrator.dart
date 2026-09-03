import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../model/model_contract.dart';

/// Integrates sequential relative displacement predictions into continuous
/// geographical coordinates (Latitude, Longitude, Heading).
class DeadReckoningIntegrator {
  LatLng _currentPosition;

  /// Current vehicle bearing in degrees (0 = North, 90 = East, 180 = South, 270 = West).
  double _currentHeadingDeg;

  /// Mean Earth radius in meters (WGS-84).
  static const double earthRadius = 6371000.0;

  DeadReckoningIntegrator({
    required LatLng initialPosition,
    required double initialHeadingDeg,
  })  : _currentPosition = initialPosition,
        _currentHeadingDeg = initialHeadingDeg;

  LatLng get currentPosition => _currentPosition;
  double get currentHeadingDeg => _currentHeadingDeg;

  /// Synchronizes the internal integrator state with an authoritative GPS fix.
  void syncWithGps(LatLng position, double headingDeg) {
    _currentPosition = position;
    _currentHeadingDeg = (headingDeg + 360) % 360;
  }

  /// Advances the dead-reckoned trajectory by integrating one model prediction.
  ///
  /// [prediction] provides forward distance traveled (meters) and heading change (radians).
  LatLng integrate(DisplacementPrediction prediction) {
    // 1. Update vehicle heading
    final deltaHeadingDeg = prediction.headingChange * (180.0 / pi);
    _currentHeadingDeg = (_currentHeadingDeg + deltaHeadingDeg + 360.0) % 360.0;

    // 2. Advance coordinates along current heading by distance
    _currentPosition = _calculateDestination(
      _currentPosition,
      prediction.distance,
      _currentHeadingDeg,
    );

    return _currentPosition;
  }

  /// Projects a point [origin] along [bearingDeg] by [distanceMeters] on spherical Earth.
  LatLng _calculateDestination(LatLng origin, double distanceMeters, double bearingDeg) {
    if (distanceMeters <= 0.0) return origin;

    final lat1 = origin.latitude * (pi / 180.0);
    final lon1 = origin.longitude * (pi / 180.0);
    final bearingRad = bearingDeg * (pi / 180.0);
    final angularDistance = distanceMeters / earthRadius;

    final lat2 = asin(
      sin(lat1) * cos(angularDistance) +
      cos(lat1) * sin(angularDistance) * cos(bearingRad),
    );

    final lon2 = lon1 + atan2(
      sin(bearingRad) * sin(angularDistance) * cos(lat1),
      cos(angularDistance) - sin(lat1) * sin(lat2),
    );

    return LatLng(lat2 * (180.0 / pi), lon2 * (180.0 / pi));
  }
}
