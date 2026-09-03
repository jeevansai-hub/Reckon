import 'dart:math';
import 'model_contract.dart';

/// A realistic mock inference engine for development and UI prototyping.
///
/// Computes plausible forward displacement from sensor energy and yaw rate,
/// simulating ~8ms on-device latency without requiring a physical .tflite weight file.
class StubModelEngine implements IInferenceEngine {
  bool _isReady = false;
  final Random _random = Random();

  @override
  String get name => 'Reckon Stub Inference (Mock)';

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    // Simulate lightweight model initialization
    await Future.delayed(const Duration(milliseconds: 150));
    _isReady = true;
  }

  @override
  Future<DisplacementPrediction> predict(List<List<double>> window) async {
    final stopwatch = Stopwatch()..start();

    // Verify window dimensions
    if (window.isEmpty || window[0].length < 6) {
      return const DisplacementPrediction(distance: 0.0, headingChange: 0.0);
    }

    // Estimate kinetic energy from linear acceleration (channels 0, 1, 2)
    double accelEnergy = 0.0;
    double yawSum = 0.0;

    for (final sample in window) {
      final ax = sample[0];
      final ay = sample[1];
      final az = sample[2];
      final yawRate = sample[3]; // Gyro yaw (rad/s)

      accelEnergy += sqrt(ax * ax + ay * ay + az * az);
      yawSum += yawRate;
    }

    final meanEnergy = accelEnergy / window.length;
    final meanYawRate = yawSum / window.length;

    // Simulate physical vehicle forward velocity (between 30 km/h and 65 km/h)
    // 5 seconds stride * ~13.8 m/s (~50 km/h) + slight sensor energy modulation
    final baseSpeedMps = 12.0 + (meanEnergy * 2.0).clamp(0.0, 6.0);
    final simulatedDistance = baseSpeedMps * 5.0 + (_random.nextDouble() * 0.8 - 0.4);

    // Heading change: integrated yaw rate over window + tiny noise
    final simulatedHeading = (meanYawRate * 5.0) + (_random.nextDouble() * 0.02 - 0.01);

    // Simulate on-device TFLite inference latency (6 - 12 ms)
    await Future.delayed(const Duration(milliseconds: 8));
    stopwatch.stop();

    return DisplacementPrediction(
      distance: simulatedDistance.clamp(0.0, 120.0),
      headingChange: simulatedHeading,
      latencyMs: stopwatch.elapsedMicroseconds / 1000.0,
    );
  }

  @override
  Future<void> dispose() async {
    _isReady = false;
  }
}
