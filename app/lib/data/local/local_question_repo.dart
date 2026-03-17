import '../../data/models/answered_question.dart';
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

    // Get accuracy by topic from user_attempts (weakest first)
    final topicStats = await db.rawQuery('''
      SELECT q.topic,
        AVG(CASE WHEN ua.is_correct = 1 THEN 1.0 ELSE 0.0 END) as accuracy
      FROM user_attempts ua
      JOIN questions q ON q.id = ua.question_id
      GROUP BY q.topic
      ORDER BY accuracy ASC
    ''');

    if (topicStats.isEmpty) {
      return getUnattemptedQuestions(limit: limit);
    }

    // Build topic → priority map (lower = weaker = higher priority)
    final topicPriority = <String, int>{};
    for (var i = 0; i < topicStats.length; i++) {
      topicPriority[topicStats[i]['topic'] as String] = i;
    }
    final defaultPriority = topicStats.length;

    // Fetch unattempted questions (random order from DB)
    final maps = await db.rawQuery('''
      SELECT * FROM questions
      WHERE id NOT IN (SELECT question_id FROM user_attempts)
      ORDER BY RANDOM()
      LIMIT ?
    ''', [limit * 3]); // Over-fetch to allow Dart-side prioritization

    // Sort in Dart by weak-topic priority, then take the limit
    final questions = maps.map(Question.fromMap).toList()
      ..sort((a, b) {
        final pa = topicPriority[a.topic] ?? defaultPriority;
        final pb = topicPriority[b.topic] ?? defaultPriority;
        return pa.compareTo(pb);
      });

    return questions.take(limit).toList();
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
        AND ua.attempted_at >= datetime('now', '-' || ? || ' days')
      ORDER BY ua.attempted_at DESC
      LIMIT ?
    ''', [days, limit]);
    return maps.map(Question.fromMap).toList();
  }

  @override
  Future<List<AnsweredQuestion>> getAnsweredQuestions({
    bool wrongOnly = false,
    int limit = 50,
  }) async {
    final db = await _dbService.database;
    final whereClause = wrongOnly ? 'WHERE ua.is_correct = 0' : '';
    final maps = await db.rawQuery('''
      SELECT q.*, ua.user_answer, ua.is_correct, ua.time_taken_seconds
      FROM questions q
      JOIN user_attempts ua ON ua.question_id = q.id
      $whereClause
      ORDER BY ua.attempted_at DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(AnsweredQuestion.fromMap).toList();
  }
}
