/// An individual 6-channel motion sensor reading taken at timestamp [time].
class SensorSample {
  final DateTime time;

  /// Gravity-corrected linear acceleration along X (lateral), Y (longitudinal), Z (vertical) in m/s^2.
  final double ax;
  final double ay;
  final double az;

  /// Angular rotation rates around X (pitch), Y (roll), Z (yaw) in rad/s.
  final double gx;
  final double gy;
  final double gz;

  const SensorSample({
    required this.time,
    required this.ax,
    required this.ay,
    required this.az,
    required this.gx,
    required this.gy,
    required this.gz,
  });

  /// Formats the sample into a 6-element list matching the model contract input order.
  List<double> toChannels() => [ax, ay, az, gx, gy, gz];
}
