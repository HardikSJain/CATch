import '../../data/models/daily_target.dart';

abstract class DailyTargetRepository {
  /// Get or create today's daily target.
  Future<DailyTarget> getOrCreateTodayTarget();

  /// Increment completion count for a section in the given mode.
  Future<void> incrementProgress(String section, String mode);

  /// Get the current consecutive-day streak.
  Future<int> getStreak();
}
