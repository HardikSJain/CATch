import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../data/models/daily_target.dart';
import '../../domain/repositories/daily_target_repository.dart';
import 'database_service.dart';

class LocalDailyTargetRepository implements DailyTargetRepository {
  final DatabaseService _dbService;

  LocalDailyTargetRepository(this._dbService);

  String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  Future<DailyTarget> getOrCreateTodayTarget() async {
    final db = await _dbService.database;
    final today = _today();

    final existing = await db.query(
      'daily_targets',
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existing.isNotEmpty) {
      return DailyTarget.fromMap(existing.first);
    }

    // Determine focus section from study schedule
    final dayOfWeek = DateTime.now().weekday;
    final schedule = await db.query(
      'study_schedule',
      where: 'day_of_week = ?',
      whereArgs: [dayOfWeek],
    );
    final focusSection = schedule.isNotEmpty
        ? schedule.first['focus_section'] as String
        : 'QA';

    final id = await db.insert('daily_targets', {
      'date': today,
      'focus_section': focusSection,
    });

    return DailyTarget(
      id: id,
      date: today,
      focusSection: focusSection,
    );
  }

  @override
  Future<void> incrementProgress(String section, String mode) async {
    final db = await _dbService.database;
    final today = _today();

    final practiceMode = PracticeMode.fromValue(mode);

    if (practiceMode == PracticeMode.dailyMin) {
      final sectionEnum = Section.fromCode(section);
      final column = switch (sectionEnum) {
        Section.dilr => 'dilr_min_completed',
        Section.qa => 'qa_min_completed',
        Section.varc => 'varc_min_completed',
      };
      await db.rawUpdate(
        'UPDATE daily_targets SET $column = $column + 1 WHERE date = ?',
        [today],
      );
    } else if (practiceMode == PracticeMode.focused) {
      await db.rawUpdate(
        'UPDATE daily_targets SET focus_completed = focus_completed + 1 WHERE date = ?',
        [today],
      );
    }
  }

  @override
  Future<int> getStreak() async {
    final db = await _dbService.database;
    final results = await db.rawQuery('''
      SELECT date FROM daily_targets
      WHERE (dilr_min_completed >= dilr_min_target
        AND qa_min_completed >= qa_min_target
        AND varc_min_completed >= varc_min_target)
      ORDER BY date DESC
    ''');

    if (results.isEmpty) return 0;

    int streak = 0;
    var checkDate = DateTime.now();

    for (final row in results) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);
      final expected = DateTime(checkDate.year, checkDate.month, checkDate.day);
      final actual = DateTime(date.year, date.month, date.day);

      if (actual == expected) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (actual == expected.subtract(const Duration(days: 1)) &&
          streak == 0) {
        // Allow yesterday as the start if today hasn't been completed yet
        streak++;
        checkDate = actual.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
