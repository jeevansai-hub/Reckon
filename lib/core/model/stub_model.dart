import 'dart:math';

/// Placeholder standing in for the trained `.tflite` model until the ML
/// side (see Project-Context/00-PROJECT-CONTEXT.md) exports `model-v1`.
///
/// Matches the real model's contract exactly (Project-Context/01-MOBILE-APP-CONTEXT.md §3):
/// a 100-timestep x 6-channel input window, and a (distanceMetres, headingChangeRadians)
/// output pair. Swapping this for `tflite_flutter` inference should be a drop-in
/// replacement once `model-v1` lands.
class StubModel {
  StubModel({int? seed}) : _random = Random(seed);

  final Random _random;

  /// One inference over a window of sensor samples.
  ///
  /// Ignores the actual window content — a real model reads the 100x6
  /// window; this stub only exists to exercise the app's plumbing.
  StubPrediction predict(List<List<double>> window) {
    final distance = 8 + _random.nextDouble() * 6; // plausible metres per 5s window
    final headingDelta = (_random.nextDouble() - 0.5) * 0.35; // radians
    return StubPrediction(distanceMetres: distance, headingChangeRadians: headingDelta);
  }
}

class StubPrediction {
  const StubPrediction({required this.distanceMetres, required this.headingChangeRadians});

  final double distanceMetres;
  final double headingChangeRadians;
}
