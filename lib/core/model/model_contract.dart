/// The prediction output from the On-Device Machine Learning Model.
class DisplacementPrediction {
  /// Physical distance traveled during the window in real-world meters.
  final double distance;

  /// Relative change in heading/bearing during the window in radians.
  final double headingChange;

  /// Inference duration in milliseconds.
  final double latencyMs;

  const DisplacementPrediction({
    required this.distance,
    required this.headingChange,
    this.latencyMs = 0.0,
  });

  @override
  String toString() =>
      'DisplacementPrediction(distance: ${distance.toStringAsFixed(2)}m, '
      'headingChange: ${headingChange.toStringAsFixed(4)}rad, '
      'latency: ${latencyMs.toStringAsFixed(1)}ms)';
}

/// Abstract contract for on-device inference engines.
///
/// Both the development [StubModelEngine] and the production [TFLiteEngine]
/// implement this interface, allowing UI and navigation logic to be fully tested
/// before and after the neural network weights are loaded.
abstract class IInferenceEngine {
  /// Human-readable name of the backend (e.g. "Stub Mock Engine" or "TFLite LSTM v1").
  String get name;

  /// Whether the engine is initialized and ready to execute inferences.
  bool get isReady;

  /// Initializes the model resources.
  Future<void> initialize();

  /// Executes inference on a rolling window of IMU measurements.
  ///
  /// [window] must contain 100 timesteps of 6 channels:
  /// [ax, ay, az, gx, gy, gz] sampled at 10 Hz.
  Future<DisplacementPrediction> predict(List<List<double>> window);

  /// Releases resources.
  Future<void> dispose();
}
