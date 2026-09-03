import 'package:flutter_test/flutter_test.dart';
import 'package:reckon/core/sensors/rolling_buffer.dart';
import 'package:reckon/core/sensors/sensor_sample.dart';

void main() {
  group('RollingSensorBuffer', () {
    test('buffers samples until windowSize is reached', () {
      final buffer = RollingSensorBuffer(windowSize: 10, stride: 5);

      for (int i = 0; i < 9; i++) {
        final result = buffer.addSample(SensorSample(
          time: DateTime.now(),
          ax: 0.1, ay: 0.2, az: 0.3,
          gx: 0.01, gy: 0.02, gz: 0.03,
        ));
        expect(result, isNull);
        expect(buffer.isFilled, isFalse);
      }

      // 10th sample fills window
      final window = buffer.addSample(SensorSample(
        time: DateTime.now(),
        ax: 0.1, ay: 0.2, az: 0.3,
        gx: 0.01, gy: 0.02, gz: 0.03,
      ));

      expect(window, isNotNull);
      expect(window!.length, 10);
      expect(window[0].length, 6);
      expect(buffer.isFilled, isTrue);
    });

    test('emits new window every stride samples after filled', () {
      final buffer = RollingSensorBuffer(windowSize: 10, stride: 3);

      // Fill buffer with 10 samples
      for (int i = 0; i < 10; i++) {
        buffer.addSample(SensorSample(
          time: DateTime.now(),
          ax: 0.1, ay: 0.2, az: 0.3,
          gx: 0.01, gy: 0.02, gz: 0.03,
        ));
      }

      // Add 2 samples (less than stride 3)
      expect(buffer.addSample(SensorSample(
        time: DateTime.now(),
        ax: 0.1, ay: 0.2, az: 0.3, gx: 0.01, gy: 0.02, gz: 0.03,
      )), isNull);

      expect(buffer.addSample(SensorSample(
        time: DateTime.now(),
        ax: 0.1, ay: 0.2, az: 0.3, gx: 0.01, gy: 0.02, gz: 0.03,
      )), isNull);

      // 3rd sample reaches stride -> emits window
      final window = buffer.addSample(SensorSample(
        time: DateTime.now(),
        ax: 0.1, ay: 0.2, az: 0.3, gx: 0.01, gy: 0.02, gz: 0.03,
      ));

      expect(window, isNotNull);
      expect(window!.length, 10);
    });
  });
}
