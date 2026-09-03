import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'rolling_buffer.dart';
import 'sensor_sample.dart';

/// Manages physical device motion sensor streams and resamples them to exactly 10 Hz.
class SensorManager {
  final RollingSensorBuffer buffer;
  final Function(List<List<double>> window)? onWindowReady;
  final Function(SensorSample latestSample)? onSampleRecorded;

  StreamSubscription? _userAccelSubscription;
  StreamSubscription? _gyroSubscription;
  Timer? _samplingTimer;

  // Latest raw sensor values
  double _latestAx = 0.0, _latestAy = 0.0, _latestAz = 0.0;
  double _latestGx = 0.0, _latestGy = 0.0, _latestGz = 0.0;

  // Static bias offsets (calculated during stationary calibration)
  double _biasAx = 0.0, _biasAy = 0.0, _biasAz = 0.0;
  double _biasGx = 0.0, _biasGy = 0.0, _biasGz = 0.0;

  bool _isListening = false;
  bool get isListening => _isListening;

  SensorManager({
    RollingSensorBuffer? buffer,
    this.onWindowReady,
    this.onSampleRecorded,
  }) : buffer = buffer ?? RollingSensorBuffer();

  /// Starts listening to phone sensors and samples at 10 Hz (every 100ms).
  void start() {
    if (_isListening) return;
    _isListening = true;

    // Listen to linear acceleration (gravity-subtracted)
    _userAccelSubscription = userAccelerometerEventStream().listen(
      (UserAccelerometerEvent event) {
        _latestAx = event.x;
        _latestAy = event.y;
        _latestAz = event.z;
      },
      onError: (e) => debugPrint('[SensorManager] Accel error: $e'),
    );

    // Listen to gyroscope rotation rate (rad/s)
    _gyroSubscription = gyroscopeEventStream().listen(
      (GyroscopeEvent event) {
        _latestGx = event.x;
        _latestGy = event.y;
        _latestGz = event.z;
      },
      onError: (e) => debugPrint('[SensorManager] Gyro error: $e'),
    );

    // Fixed 10 Hz sampling timer (100 ms) matching IO-VNBD dataset rate
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      final sample = SensorSample(
        time: DateTime.now(),
        ax: _latestAx - _biasAx,
        ay: _latestAy - _biasAy,
        az: _latestAz - _biasAz,
        gx: _latestGx - _biasGx,
        gy: _latestGy - _biasGy,
        gz: _latestGz - _biasGz,
      );

      onSampleRecorded?.call(sample);

      final window = buffer.addSample(sample);
      if (window != null) {
        onWindowReady?.call(window);
      }
    });

    debugPrint('[SensorManager] 10 Hz motion sampling loop started.');
  }

  /// Sets stationary IMU calibration biases to subtract constant sensor offsets.
  void setBiases({
    double ax = 0.0,
    double ay = 0.0,
    double az = 0.0,
    double gx = 0.0,
    double gy = 0.0,
    double gz = 0.0,
  }) {
    _biasAx = ax;
    _biasAy = ay;
    _biasAz = az;
    _biasGx = gx;
    _biasGy = gy;
    _biasGz = gz;
    debugPrint('[SensorManager] Stationary biases updated.');
  }

  /// Stops sampling and releases sensor stream subscriptions.
  void stop() {
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _userAccelSubscription?.cancel();
    _userAccelSubscription = null;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _isListening = false;
    debugPrint('[SensorManager] Motion sensors stopped.');
  }

  void dispose() {
    stop();
    buffer.clear();
  }
}
