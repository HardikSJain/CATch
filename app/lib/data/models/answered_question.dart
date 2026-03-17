import 'question.dart';

/// A question paired with the user's attempt data for review.
class AnsweredQuestion {
  final Question question;
  final String userAnswer;
  final bool isCorrect;
  final int? timeTakenSeconds;

  const AnsweredQuestion({
    required this.question,
    required this.userAnswer,
    required this.isCorrect,
    this.timeTakenSeconds,
  });

  factory AnsweredQuestion.fromMap(Map<String, dynamic> map) {
    return AnsweredQuestion(
      question: Question.fromMap(map),
      userAnswer: map['user_answer'] as String,
      isCorrect: (map['is_correct'] as int) == 1,
      timeTakenSeconds: map['time_taken_seconds'] as int?,
    );
  }
}
