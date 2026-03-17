abstract class AttemptRepository {
  /// Submit an answer. Uses INSERT OR REPLACE (UNIQUE on question_id).
  Future<void> submitAnswer({
    required int questionId,
    required String userAnswer,
    required bool isCorrect,
    required String mode,
    int? timeTakenSeconds,
  });

  /// Get accuracy by topic for adaptive question selection.
  Future<Map<String, double>> getAccuracyByTopic();

  /// Get the total number of attempts.
  Future<int> getTotalAttempts();
}
