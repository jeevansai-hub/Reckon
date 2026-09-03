import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:reckon/core/navigation/fusion_blender.dart';

void main() {
  group('FusionBlender', () {
    test('returns pure GPS when not blending', () {
      final blender = FusionBlender(blendDurationSeconds: 2.0);
      final gps = const LatLng(52.4068, -1.5197);

      expect(blender.isBlending, isFalse);
      expect(blender.update(gps), equals(gps));
    });

    test('blends smoothly between dead reckoned start and new GPS', () async {
      final blender = FusionBlender(blendDurationSeconds: 1.0);
      final drStart = const LatLng(52.4000, -1.5000);
      final gpsEnd = const LatLng(52.4010, -1.5010);

      blender.startBlend(drStart);
      expect(blender.isBlending, isTrue);

      // Immediate update should be very close to drStart
      final immediatePos = blender.update(gpsEnd);
      expect((immediatePos.latitude - drStart.latitude).abs(), lessThan(0.0003));

      // After elapsed duration, should reach gpsEnd
      await Future.delayed(const Duration(milliseconds: 1050));
      final finalPos = blender.update(gpsEnd);
      expect(blender.isBlending, isFalse);
      expect(finalPos.latitude, closeTo(gpsEnd.latitude, 0.00001));
    });
  });
}
