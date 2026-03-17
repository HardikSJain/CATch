import '../../data/models/question.dart';
import '../../domain/repositories/question_repository.dart';
import 'database_service.dart';

class LocalQuestionRepository implements QuestionRepository {
  final DatabaseService _dbService;

  LocalQuestionRepository(this._dbService);

  @override
  Future<List<Question>> getUnattemptedQuestions({
    String? section,
    int limit = 30,
  }) async {
    final db = await _dbService.database;
    final where = StringBuffer(
      'id NOT IN (SELECT question_id FROM user_attempts)',
    );
    final args = <dynamic>[];

    if (section != null) {
      where.write(' AND section = ?');
      args.add(section);
    }

    final maps = await db.query(
      'questions',
      where: where.toString(),
      whereArgs: args,
      limit: limit,
      orderBy: 'RANDOM()',
    );
    return maps.map(Question.fromMap).toList();
  }

  @override
  Future<List<Question>> getAdaptiveQuestions({int limit = 30}) async {
    final db = await _dbService.database;

    // Get accuracy by topic from user_attempts
    final topicStats = await db.rawQuery('''
      SELECT q.topic, q.section,
        AVG(CASE WHEN ua.is_correct = 1 THEN 1.0 ELSE 0.0 END) as accuracy,
        COUNT(*) as attempts
      FROM user_attempts ua
      JOIN questions q ON q.id = ua.question_id
      GROUP BY q.topic
      ORDER BY accuracy ASC
    ''');

    if (topicStats.isEmpty) {
      // No attempts yet — fall back to random
      return getUnattemptedQuestions(limit: limit);
    }

    // Build ordered topic list (weakest first)
    final weakTopics = topicStats
        .map((row) => row['topic'] as String)
        .toList();

    // Fetch unattempted questions prioritizing weak topics
    final caseOrder = weakTopics.asMap().entries
        .map((e) => "WHEN topic = '${e.value}' THEN ${e.key}")
        .join(' ');

    final maps = await db.rawQuery('''
      SELECT * FROM questions
      WHERE id NOT IN (SELECT question_id FROM user_attempts)
      ORDER BY CASE $caseOrder ELSE ${weakTopics.length} END, RANDOM()
      LIMIT ?
    ''', [...weakTopics, limit]);

    // Note: we don't use weakTopics as whereArgs in CASE since they're
    // inlined; the placeholders approach would be complex for CASE WHEN.
    // The LIMIT is the only bound param.

    return maps.map(Question.fromMap).toList();
  }

  @override
  Future<List<Question>> getQuestionsBySetId(int setId) async {
    final db = await _dbService.database;
    final maps = await db.query(
      'questions',
      where: 'set_id = ?',
      whereArgs: [setId],
      orderBy: 'id ASC',
    );
    return maps.map(Question.fromMap).toList();
  }

  @override
  Future<List<Question>> getMissedQuestions({
    int days = 7,
    int limit = 30,
  }) async {
    final db = await _dbService.database;
    final maps = await db.rawQuery('''
      SELECT q.* FROM questions q
      JOIN user_attempts ua ON ua.question_id = q.id
      WHERE ua.is_correct = 0
        AND ua.attempted_at >= datetime('now', '-$days days')
      ORDER BY ua.attempted_at DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(Question.fromMap).toList();
  }
}
