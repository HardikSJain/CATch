import '../../domain/repositories/stats_repository.dart';
import 'database_service.dart';

class LocalStatsRepository implements StatsRepository {
  final DatabaseService _dbService;

  LocalStatsRepository(this._dbService);

  @override
  Future<Map<String, dynamic>> getOverallStats() async {
    final db = await _dbService.database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total,
        SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct
      FROM user_attempts
    ''');

    final total = (result.first['total'] as int?) ?? 0;
    final correct = (result.first['correct'] as int?) ?? 0;
    final accuracy = total > 0 ? (correct / total * 100).round() : 0;

    return {
      'total': total,
      'correct': correct,
      'accuracy': accuracy,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getStatsByTopic() async {
    final db = await _dbService.database;
    return db.rawQuery('''
      SELECT
        q.section,
        q.topic,
        COUNT(*) as total,
        SUM(CASE WHEN ua.is_correct = 1 THEN 1 ELSE 0 END) as correct,
        AVG(CASE WHEN ua.is_correct = 1 THEN 1.0 ELSE 0.0 END) as accuracy
      FROM user_attempts ua
      JOIN questions q ON q.id = ua.question_id
      GROUP BY q.section, q.topic
      ORDER BY q.section, accuracy ASC
    ''');
  }

  @override
  Future<List<Map<String, dynamic>>> getDailyAccuracy({int days = 30}) async {
    final db = await _dbService.database;
    return db.rawQuery('''
      SELECT
        DATE(attempted_at) as date,
        COUNT(*) as total,
        SUM(CASE WHEN is_correct = 1 THEN 1 ELSE 0 END) as correct,
        AVG(CASE WHEN is_correct = 1 THEN 1.0 ELSE 0.0 END) as accuracy
      FROM user_attempts
      WHERE attempted_at >= datetime('now', '-' || ? || ' days')
      GROUP BY DATE(attempted_at)
      ORDER BY date ASC
    ''', [days]);
  }
}
