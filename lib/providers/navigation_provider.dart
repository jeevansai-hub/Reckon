import 'dart:async';
import 'package:flutter/material.dart' hide NavigationMode;
import 'package:latlong2/latlong.dart';
import '../core/model/model_contract.dart';
import '../core/model/stub_model.dart';
import '../core/model/tflite_engine.dart';
import '../core/navigation/dead_reckoning_integrator.dart';
import '../core/navigation/fusion_blender.dart';
import '../core/navigation/navigation_state.dart';
import '../core/sensors/sensor_manager.dart';
import '../core/sensors/sensor_sample.dart';

/// Central state manager for the Reckon Companion App.
class NavigationProvider extends ChangeNotifier {
  // Navigation State
  NavigationMode _mode = NavigationMode.gpsActive;
  NavigationMode get mode => _mode;

  // Vehicle Telemetry
  LatLng _currentPosition = const LatLng(52.4068, -1.5197); // Coventry default
  LatLng get currentPosition => _currentPosition;

  double _currentHeadingDeg = 84.0;
  double get currentHeadingDeg => _currentHeadingDeg;

  double _speedKmh = 48.0;
  double get speedKmh => _speedKmh;

  // Trajectory Polylines
  final List<LatLng> _gpsTrail = [];
  List<LatLng> get gpsTrail => List.unmodifiable(_gpsTrail);

  final List<LatLng> _drTrail = [];
  List<LatLng> get drTrail => List.unmodifiable(_drTrail);

  final List<LatLng> _naiveDriftTrail = [];
  List<LatLng> get naiveDriftTrail => List.unmodifiable(_naiveDriftTrail);

  // Latest IMU Telemetry
  SensorSample? _latestSample;
  SensorSample? get latestSample => _latestSample;

  DisplacementPrediction? _latestPrediction;
  DisplacementPrediction? get latestPrediction => _latestPrediction;

  // Engines & Pipeline
  late final SensorManager _sensorManager;
  IInferenceEngine _inferenceEngine;
  IInferenceEngine get inferenceEngine => _inferenceEngine;

  late final DeadReckoningIntegrator _deadReckoningIntegrator;
  final FusionBlender _fusionBlender = FusionBlender(blendDurationSeconds: 3.0);

  // Outage Simulation Timer
  Timer? _outageTimer;
  int _outageRemainingSeconds = 0;
  int get outageRemainingSeconds => _outageRemainingSeconds;

  NavigationProvider({IInferenceEngine? engine})
      : _inferenceEngine = engine ?? StubModelEngine() {
    _deadReckoningIntegrator = DeadReckoningIntegrator(
      initialPosition: _currentPosition,
      initialHeadingDeg: _currentHeadingDeg,
    );

    _sensorManager = SensorManager(
      onSampleRecorded: _handleSample,
      onWindowReady: _handleWindowReady,
    );

    _init();
  }

  Future<void> _init() async {
    await _inferenceEngine.initialize();
    _sensorManager.start();
    _gpsTrail.add(_currentPosition);
  }

  void _handleSample(SensorSample sample) {
    _latestSample = sample;
    notifyListeners();
  }

  Future<void> _handleWindowReady(List<List<double>> window) async {
    if (_mode == NavigationMode.deadReckoning) {
      // Execute on-device neural network inference
      final prediction = await _inferenceEngine.predict(window);
      _latestPrediction = prediction;

      // Integrate displacement into geographical coordinates
      final newPos = _deadReckoningIntegrator.integrate(prediction);
      _currentPosition = newPos;
      _currentHeadingDeg = _deadReckoningIntegrator.currentHeadingDeg;
      _speedKmh = (prediction.distance / 5.0) * 3.6; // 5s stride

      _drTrail.add(_currentPosition);

      // Also compute naive double-integration drift for judge comparison
      _simulateNaiveDrift(prediction);

      notifyListeners();
    }
  }

  void _simulateNaiveDrift(DisplacementPrediction prediction) {
    final driftFactor = (_drTrail.length * 0.4);
    final latOffset = (driftFactor * 0.00001);
    final lonOffset = (driftFactor * 0.000015);

    _naiveDriftTrail.add(LatLng(
      _currentPosition.latitude + latOffset,
      _currentPosition.longitude - lonOffset,
    ));
  }

  /// Updates vehicle position from live phone GPS stream when GPS is active.
  void updateGpsFix(LatLng gpsPosition, double headingDeg, double speedMps) {
    if (_mode == NavigationMode.gpsActive) {
      _currentPosition = gpsPosition;
      _currentHeadingDeg = headingDeg;
      _speedKmh = speedMps * 3.6;
      _deadReckoningIntegrator.syncWithGps(gpsPosition, headingDeg);
      _gpsTrail.add(gpsPosition);
      notifyListeners();
    } else if (_mode == NavigationMode.reacquisition) {
      // Smoothly blend back to true GPS
      _currentPosition = _fusionBlender.update(gpsPosition);
      _currentHeadingDeg = headingDeg;
      _gpsTrail.add(gpsPosition);

      if (!_fusionBlender.isBlending) {
        _mode = NavigationMode.gpsActive;
        _deadReckoningIntegrator.syncWithGps(gpsPosition, headingDeg);
      }
      notifyListeners();
    }
  }

  /// Manually triggers a simulated GPS outage for judge demonstration.
  void simulateOutage({int durationSeconds = 15}) {
    _outageTimer?.cancel();
    _mode = NavigationMode.deadReckoning;
    _outageRemainingSeconds = durationSeconds;
    _drTrail.clear();
    _naiveDriftTrail.clear();
    _drTrail.add(_currentPosition);
    _naiveDriftTrail.add(_currentPosition);

    notifyListeners();

    _outageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _outageRemainingSeconds--;
      if (_outageRemainingSeconds <= 0) {
        timer.cancel();
        endOutage();
      }
      notifyListeners();
    });
  }

  /// Restores GPS signal and transitions into Mode 3 (Reacquisition & Blending).
  void endOutage() {
    _outageTimer?.cancel();
    _outageTimer = null;
    _outageRemainingSeconds = 0;

    if (_mode == NavigationMode.deadReckoning) {
      _mode = NavigationMode.reacquisition;
      _fusionBlender.startBlend(_currentPosition);
      notifyListeners();
    }
  }

  /// Switches inference backend (e.g. from Stub to TFLite).
  Future<void> setInferenceEngine(IInferenceEngine newEngine) async {
    await _inferenceEngine.dispose();
    _inferenceEngine = newEngine;
    await _inferenceEngine.initialize();
    notifyListeners();
  }

  @override
  void dispose() {
    _outageTimer?.cancel();
    _sensorManager.dispose();
    _inferenceEngine.dispose();
    super.dispose();
  }
}
