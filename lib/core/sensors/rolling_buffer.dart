import 'dart:collection';
import 'sensor_sample.dart';

/// A rolling FIFO buffer that slices continuous sensor streams into fixed-size
/// overlapping evaluation windows matching the neural network input contract.
///
/// Default configuration:
/// - [windowSize] = 100 samples (10 seconds @ 10 Hz)
/// - [stride] = 50 samples (new window ready every 5 seconds)
class RollingSensorBuffer {
  final int windowSize;
  final int stride;

  final Queue<SensorSample> _buffer = Queue<SensorSample>();
  int _samplesSinceLastEmit = 0;

  RollingSensorBuffer({
    this.windowSize = 100,
    this.stride = 50,
  });

  /// Current number of samples in the buffer.
  int get length => _buffer.length;

  /// Whether the buffer has enough samples to form a complete window.
  bool get isFilled => _buffer.length >= windowSize;

  /// Adds a new sensor sample to the buffer.
  ///
  /// Returns a `List<List<double>>` of shape `[windowSize, 6]` if a new stride
  /// window is ready, or `null` otherwise.
  List<List<double>>? addSample(SensorSample sample) {
    _buffer.addLast(sample);
    _samplesSinceLastEmit++;

    // Evict oldest sample if exceeding windowSize
    while (_buffer.length > windowSize) {
      _buffer.removeFirst();
    }

    // Check if ready to emit
    if (_buffer.length == windowSize && _samplesSinceLastEmit >= stride) {
      _samplesSinceLastEmit = 0;
      return getWindow();
    }

    return null;
  }

  /// Extracts the current window formatted as a [windowSize x 6] array of doubles.
  List<List<double>> getWindow() {
    return _buffer.map((sample) => sample.toChannels()).toList();
  }

  /// Clears the buffer state.
  void clear() {
    _buffer.clear();
    _samplesSinceLastEmit = 0;
  }
}
