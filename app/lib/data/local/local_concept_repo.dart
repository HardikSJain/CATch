import 'package:intl/intl.dart';
import '../../core/sm2.dart';
import '../../domain/repositories/concept_repository.dart';
import 'database_service.dart';

class LocalConceptRepository implements ConceptRepository {
  final DatabaseService _dbService;

  LocalConceptRepository(this._dbService);

  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Future<List<Map<String, dynamic>>> getConcepts({
    required String section,
  }) async {
    final db = await _dbService.database;
    return db.query(
      'concepts',
      where: 'section = ?',
      whereArgs: [section],
      orderBy: 'sort_order ASC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getDueForReview() async {
    final db = await _dbService.database;
    final today = _today();

    return db.rawQuery('''
      SELECT c.*, cr.ease_factor, cr.repetitions, cr.interval_days,
        cr.next_review_date, cr.last_reviewed_at
      FROM concepts c
      LEFT JOIN concept_reviews cr ON cr.concept_id = c.id
      WHERE cr.next_review_date IS NULL
        OR cr.next_review_date <= ?
      ORDER BY cr.next_review_date ASC NULLS FIRST
    ''', [today]);
  }

  @override
  Future<int> getDueForReviewCount() async {
    final db = await _dbService.database;
    final today = _today();

    final result = await db.rawQuery('''
      SELECT COUNT(*) as cnt FROM concepts c
      LEFT JOIN concept_reviews cr ON cr.concept_id = c.id
      WHERE cr.next_review_date IS NULL
        OR cr.next_review_date <= ?
    ''', [today]);

    return (result.first['cnt'] as int?) ?? 0;
  }

  @override
  Future<void> rateReview({
    required int conceptId,
    required int quality,
  }) async {
    final db = await _dbService.database;
    final today = _today();

    // Get current review state
    final existing = await db.query(
      'concept_reviews',
      where: 'concept_id = ?',
      whereArgs: [conceptId],
    );

    final double currentEf;
    final int currentReps;
    final int currentInterval;

    if (existing.isNotEmpty) {
      final row = existing.first;
      currentEf = (row['ease_factor'] as num?)?.toDouble() ?? 2.5;
      currentReps = (row['repetitions'] as int?) ?? 0;
      currentInterval = (row['interval_days'] as int?) ?? 0;
    } else {
      currentEf = 2.5;
      currentReps = 0;
      currentInterval = 0;
    }

    final result = calculateSm2(
      quality: quality,
      easeFactor: currentEf,
      repetitions: currentReps,
      interval: currentInterval,
    );

    final nextReviewDate = DateTime.now().add(
      Duration(days: result.interval),
    );
    final nextReviewStr = DateFormat('yyyy-MM-dd').format(nextReviewDate);

    final reviewData = {
      'concept_id': conceptId,
      'ease_factor': result.easeFactor,
      'repetitions': result.repetitions,
      'interval_days': result.interval,
      'next_review_date': nextReviewStr,
      'last_reviewed_at': today,
    };

    if (existing.isNotEmpty) {
      await db.update(
        'concept_reviews',
        reviewData,
        where: 'concept_id = ?',
        whereArgs: [conceptId],
      );
    } else {
      await db.insert('concept_reviews', reviewData);
    }
  }
}
