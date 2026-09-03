import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'model_contract.dart';

/// Production on-device TensorFlow Lite inference engine.
///
/// Loads and executes the trained LSTM model exported from Reckon-AI.
/// Input: Tensor shape [1, 100, 6] (Float32)
/// Output: Tensor shape [1, 2] -> [distance_meters, heading_change_radians]
class TFLiteEngine implements IInferenceEngine {
  final String modelPath;
  Interpreter? _interpreter;
  bool _isReady = false;

  TFLiteEngine({this.modelPath = 'assets/models/model-v1.tflite'});

  @override
  String get name => 'Reckon On-Device TFLite (LSTM)';

  @override
  bool get isReady => _isReady;

  @override
  Future<void> initialize() async {
    try {
      final options = InterpreterOptions()..threads = 2;
      _interpreter = await Interpreter.fromAsset(modelPath, options: options);
      _interpreter!.allocateTensors();
      _isReady = true;
      debugPrint('[TFLiteEngine] Loaded model from $modelPath successfully.');
    } catch (e) {
      _isReady = false;
      debugPrint('[TFLiteEngine] Warning: Could not load $modelPath ($e). Fall back to StubModelEngine.');
    }
  }

  @override
  Future<DisplacementPrediction> predict(List<List<double>> window) async {
    if (!_isReady || _interpreter == null) {
      throw StateError('TFLiteEngine is not initialized. Call initialize() first.');
    }

    final stopwatch = Stopwatch()..start();

    // Prepare 3D input tensor: [1, 100, 6]
    final inputTensor = [window];

    // Prepare 2D output tensor: [1, 2]
    final outputTensor = List.generate(1, (_) => List.filled(2, 0.0));

    // Run on-device inference
    _interpreter!.run(inputTensor, outputTensor);
    stopwatch.stop();

    final predictedDistance = outputTensor[0][0];
    final predictedHeading = outputTensor[0][1];

    return DisplacementPrediction(
      distance: predictedDistance,
      headingChange: predictedHeading,
      latencyMs: stopwatch.elapsedMicroseconds / 1000.0,
    );
  }

  @override
  Future<void> dispose() async {
    _interpreter?.close();
    _interpreter = null;
    _isReady = false;
  }
}
