import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/settings_repository.dart';
import 'database_service.dart';

class LocalSettingsRepository implements SettingsRepository {
  final DatabaseService _dbService;

  LocalSettingsRepository(this._dbService);

  @override
  Future<DateTime?> getCatExamDate() async {
    final value = await getSetting('cat_exam_date');
    if (value == null) return null;
    return DateTime.tryParse(value);
  }

  @override
  Future<void> setCatExamDate(DateTime date) async {
    await setSetting(
      'cat_exam_date',
      date.toIso8601String().split('T').first,
    );
  }

  @override
  Future<String?> getSetting(String key) async {
    final db = await _dbService.database;
    final results = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }

  @override
  Future<void> setSetting(String key, String value) async {
    final db = await _dbService.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
