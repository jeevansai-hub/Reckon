import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:reckon/core/model/model_contract.dart';
import 'package:reckon/core/navigation/dead_reckoning_integrator.dart';

void main() {
  group('DeadReckoningIntegrator', () {
    test('advances position northward when heading is 0 degrees', () {
      final initial = const LatLng(52.4068, -1.5197);
      final integrator = DeadReckoningIntegrator(
        initialPosition: initial,
        initialHeadingDeg: 0.0,
      );

      // Travel 100 meters due North (heading change = 0)
      final newPos = integrator.integrate(
        const DisplacementPrediction(distance: 100.0, headingChange: 0.0),
      );

      // Latitude should increase (moving North)
      expect(newPos.latitude, greaterThan(initial.latitude));
      // Longitude should stay nearly identical
      expect((newPos.longitude - initial.longitude).abs(), lessThan(0.0001));
    });

    test('updates heading degrees correctly from radian delta', () {
      final integrator = DeadReckoningIntegrator(
        initialPosition: const LatLng(52.4068, -1.5197),
        initialHeadingDeg: 90.0, // Facing East
      );

      // Turn 90 degrees clockwise (pi/2 radians)
      integrator.integrate(
        const DisplacementPrediction(distance: 10.0, headingChange: 1.5707963),
      );

      // Heading should now be roughly 180 degrees (South)
      expect(integrator.currentHeadingDeg, closeTo(180.0, 0.5));
    });
  });
}
