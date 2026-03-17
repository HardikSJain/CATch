import '../../data/models/question.dart';

abstract class QuestionRepository {
  /// Get unattempted questions, optionally filtered by section.
  Future<List<Question>> getUnattemptedQuestions({
    String? section,
    int limit = 30,
  });

  /// Get questions using weak-topic-first adaptive selection.
  /// Falls back to random if no attempt history exists.
  Future<List<Question>> getAdaptiveQuestions({int limit = 30});

  /// Get questions belonging to a specific question set (caselet).
  Future<List<Question>> getQuestionsBySetId(int setId);

  /// Get previously wrong questions from the last [days] days.
  Future<List<Question>> getMissedQuestions({int days = 7, int limit = 30});
}
