import 'package:flutter_test/flutter_test.dart';
import 'package:catch_app/core/sm2.dart';

void main() {
  group('SM-2 Algorithm', () {
    test('quality >= 3 with reps=0 → interval=1', () {
      final result = calculateSm2(
        quality: 4,
        easeFactor: 2.5,
        repetitions: 0,
        interval: 0,
      );
      expect(result.interval, 1);
      expect(result.repetitions, 1);
    });

    test('quality >= 3 with reps=1 → interval=6', () {
      final result = calculateSm2(
        quality: 4,
        easeFactor: 2.5,
        repetitions: 1,
        interval: 1,
      );
      expect(result.interval, 6);
      expect(result.repetitions, 2);
    });

    test('quality >= 3 with reps=2 → interval *= easeFactor', () {
      final result = calculateSm2(
        quality: 4,
        easeFactor: 2.5,
        repetitions: 2,
        interval: 6,
      );
      // 6 * 2.5 = 15
      expect(result.interval, 15);
      expect(result.repetitions, 3);
    });

    test('quality < 3 → reps reset to 0, interval=1', () {
      final result = calculateSm2(
        quality: 2,
        easeFactor: 2.5,
        repetitions: 5,
        interval: 30,
      );
      expect(result.interval, 1);
      expect(result.repetitions, 0);
    });

    test('ease factor never drops below 1.3', () {
      final result = calculateSm2(
        quality: 0,
        easeFactor: 1.3,
        repetitions: 0,
        interval: 1,
      );
      expect(result.easeFactor, 1.3);
    });

    test('quality=5 (perfect) increases ease factor', () {
      final result = calculateSm2(
        quality: 5,
        easeFactor: 2.5,
        repetitions: 0,
        interval: 0,
      );
      expect(result.easeFactor, greaterThan(2.5));
    });

    test('quality=3 (threshold) slightly decreases ease factor', () {
      final result = calculateSm2(
        quality: 3,
        easeFactor: 2.5,
        repetitions: 0,
        interval: 0,
      );
      expect(result.easeFactor, lessThan(2.5));
    });

    test('quality=0 (complete blackout) maximally decreases ease', () {
      final result = calculateSm2(
        quality: 0,
        easeFactor: 2.5,
        repetitions: 3,
        interval: 15,
      );
      expect(result.repetitions, 0);
      expect(result.interval, 1);
      // EF: 2.5 + (0.1 - 5*(0.08 + 5*0.02)) = 2.5 + (0.1 - 0.9) = 1.7
      expect(result.easeFactor, closeTo(1.7, 0.01));
    });

    test('interval is always at least 1 (clamp)', () {
      final result = calculateSm2(
        quality: 1,
        easeFactor: 1.3,
        repetitions: 0,
        interval: 0,
      );
      expect(result.interval, greaterThanOrEqualTo(1));
    });

    test('multiple successful reviews increase interval exponentially', () {
      var ef = 2.5;
      var reps = 0;
      var interval = 0;

      // Simulate 5 perfect reviews
      for (var i = 0; i < 5; i++) {
        final result = calculateSm2(
          quality: 5,
          easeFactor: ef,
          repetitions: reps,
          interval: interval,
        );
        ef = result.easeFactor;
        reps = result.repetitions;
        interval = result.interval;
      }

      // After 5 perfect reviews, interval should be substantial
      expect(interval, greaterThan(20));
      expect(reps, 5);
      expect(ef, greaterThan(2.5));
    });
  });
}
