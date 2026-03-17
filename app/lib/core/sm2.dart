import 'dart:math';

/// SM-2 spaced repetition algorithm result.
class Sm2Result {
  final double easeFactor;
  final int repetitions;
  final int interval;

  const Sm2Result({
    required this.easeFactor,
    required this.repetitions,
    required this.interval,
  });
}

/// Pure implementation of the SM-2 algorithm.
///
/// [quality] — user rating 0–5 (0=complete blackout, 5=perfect recall)
/// [easeFactor] — current ease factor (≥1.3)
/// [repetitions] — current successful repetition count
/// [interval] — current interval in days
///
/// Returns new [Sm2Result] with updated ease, repetitions, and interval.
///
/// ```
/// INPUT: quality, easeFactor, repetitions, interval
///   │
///   ├── quality >= 3 (recalled successfully)
///   │     ├── reps == 0 → interval = 1
///   │     ├── reps == 1 → interval = 6
///   │     └── reps >= 2 → interval = (interval * EF).round()
///   │     reps += 1
///   │
///   └── quality < 3 (failed recall)
///         reps = 0
///         interval = 1
///
///   EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
///   EF  = max(1.3, EF')
///   interval = max(1, interval)  ← clamp to prevent zero/negative
/// ```
Sm2Result calculateSm2({
  required int quality,
  required double easeFactor,
  required int repetitions,
  required int interval,
}) {
  assert(quality >= 0 && quality <= 5, 'Quality must be 0-5');

  int newReps = repetitions;
  int newInterval = interval;
  double newEf = easeFactor;

  if (quality >= 3) {
    // Successful recall
    if (newReps == 0) {
      newInterval = 1;
    } else if (newReps == 1) {
      newInterval = 6;
    } else {
      newInterval = (newInterval * newEf).round();
    }
    newReps += 1;
  } else {
    // Failed recall — reset
    newReps = 0;
    newInterval = 1;
  }

  // Update ease factor
  newEf = newEf + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  newEf = max(1.3, newEf);

  // Clamp interval to prevent zero or negative
  newInterval = max(1, newInterval);

  return Sm2Result(
    easeFactor: newEf,
    repetitions: newReps,
    interval: newInterval,
  );
}
