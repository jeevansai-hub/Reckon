import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../core/model/stub_model.dart';

enum PositionMode { gps, sensorOnly, fusion }

extension PositionModeLabel on PositionMode {
  String get label => switch (this) {
        PositionMode.gps => 'GPS',
        PositionMode.sensorOnly => 'Sensor-only',
        PositionMode.fusion => 'Reconnecting',
      };

  String get key => switch (this) {
        PositionMode.gps => 'gps',
        PositionMode.sensorOnly => 'sensorOnly',
        PositionMode.fusion => 'fusion',
      };
}

/// Drives the live map: current mode, position, and travelled path.
///
/// This mirrors the app architecture in Project-Context/01-MOBILE-APP-CONTEXT.md §6
/// (Sensor Manager -> Signal Quality Monitor -> On-Device Model -> Position Integrator
/// -> Fusion Blender) using simulated GPS ticks and the [StubModel] in place of real
/// phone sensors and a trained model, so the full mode-switching flow can be built
/// and demoed before either exists.
class NavigationProvider extends ChangeNotifier {
  NavigationProvider() {
    _start();
  }

  static const _fusionBlendTicks = 4; // ~2-5s blend window, per the app contract

  final StubModel _model = StubModel();
  final Random _random = Random();
  Timer? _timer;

  PositionMode _mode = PositionMode.gps;
  LatLng _position = const LatLng(28.6139, 77.2090); // New Delhi, arbitrary demo start
  double _heading = 0;
  final List<LatLng> _path = [];

  bool _outageActive = false;
  int _outageTicksRemaining = 0;
  int _fusionTicksRemaining = 0;

  PositionMode get mode => _mode;
  LatLng get position => _position;
  double get heading => _heading;
  List<LatLng> get path => List.unmodifiable(_path);
  bool get outageActive => _outageActive;

  double _tripDistanceMetres = 0;
  double get tripDistanceMetres => _tripDistanceMetres;

  void _start() {
    _path.add(_position);
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) => _tick());
  }

  void _tick() {
    if (_outageActive) {
      _outageTicksRemaining--;
      if (_outageTicksRemaining <= 0) {
        _outageActive = false;
        _fusionTicksRemaining = _fusionBlendTicks;
      }
    }

    if (_outageActive) {
      _mode = PositionMode.sensorOnly;
      final prediction = _model.predict(const []);
      _heading += prediction.headingChangeRadians;
      _advance(prediction.distanceMetres);
    } else if (_fusionTicksRemaining > 0) {
      _mode = PositionMode.fusion;
      _fusionTicksRemaining--;
      _advance(9 + _random.nextDouble() * 4);
    } else {
      _mode = PositionMode.gps;
      _heading += (_random.nextDouble() - 0.5) * 0.15;
      _advance(9 + _random.nextDouble() * 4);
    }

    notifyListeners();
  }

  void _advance(double distanceMetres) {
    const metresPerDegreeLat = 111320.0;
    final metresPerDegreeLng = 111320.0 * cos(_position.latitude * pi / 180);

    final dLat = (distanceMetres * cos(_heading)) / metresPerDegreeLat;
    final dLng = (distanceMetres * sin(_heading)) / metresPerDegreeLng;

    _position = LatLng(_position.latitude + dLat, _position.longitude + dLng);
    _path.add(_position);
    _tripDistanceMetres += distanceMetres;
  }

  /// Judge-facing outage demo (Project-Context §5.3): simulate a GPS outage
  /// of [durationSeconds] without needing to physically drive into a tunnel.
  void triggerOutage({int durationSeconds = 12}) {
    if (_outageActive) return;
    _outageActive = true;
    _outageTicksRemaining = (durationSeconds * 1000 / 900).round();
    notifyListeners();
  }

  void resetTrip() {
    _path
      ..clear()
      ..add(_position);
    _tripDistanceMetres = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
