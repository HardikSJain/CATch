import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/attempt_repository.dart';
import 'database_service.dart';

class LocalAttemptRepository implements AttemptRepository {
  final DatabaseService _dbService;

  LocalAttemptRepository(this._dbService);

  @override
  Future<void> submitAnswer({
    required int questionId,
    required String userAnswer,
    required bool isCorrect,
    required String mode,
    int? timeTakenSeconds,
  }) async {
    final db = await _dbService.database;
    await db.insert(
      'user_attempts',
      {
        'question_id': questionId,
        'user_answer': userAnswer,
        'is_correct': isCorrect ? 1 : 0,
        'attempt_mode': mode,
        'time_taken_seconds': timeTakenSeconds,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Map<String, double>> getAccuracyByTopic() async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT q.topic,
        AVG(CASE WHEN ua.is_correct = 1 THEN 1.0 ELSE 0.0 END) as accuracy
      FROM user_attempts ua
      JOIN questions q ON q.id = ua.question_id
      GROUP BY q.topic
    ''');

    final map = <String, double>{};
    for (final row in results) {
      map[row['topic'] as String] = (row['accuracy'] as num).toDouble();
    }
    return map;
  }

  @override
  Future<int> getTotalAttempts() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM user_attempts');
    return (result.first['cnt'] as int?) ?? 0;
  }
}
