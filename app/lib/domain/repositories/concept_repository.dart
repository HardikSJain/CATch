abstract class ConceptRepository {
  /// Get concepts for a section (for the Learn screen).
  Future<List<Map<String, dynamic>>> getConcepts({required String section});

  /// Get concepts due for SM-2 review today.
  Future<List<Map<String, dynamic>>> getDueForReview();

  /// Get the count of concepts due for review today.
  Future<int> getDueForReviewCount();

  /// Record a review rating and update SM-2 scheduling.
  Future<void> rateReview({
    required int conceptId,
    required int quality,
  });
}
