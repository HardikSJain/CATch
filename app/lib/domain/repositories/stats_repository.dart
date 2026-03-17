abstract class StatsRepository {
  /// Get overall stats: {total, correct, accuracy}.
  Future<Map<String, dynamic>> getOverallStats();

  /// Get accuracy broken down by section and topic.
  Future<List<Map<String, dynamic>>> getStatsByTopic();

  /// Get daily accuracy for the last [days] days (for chart).
  Future<List<Map<String, dynamic>>> getDailyAccuracy({int days = 30});
}
