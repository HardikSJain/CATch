import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

/// Reads JSON seed files from assets and inserts into DB.
/// Tracks seed version in app_settings to avoid re-importing.
class SeedService {
  final DatabaseService _dbService;

  SeedService(this._dbService);

  Future<void> seedIfNeeded() async {
    final db = await _dbService.database;

    await _seedFromJson(
      db: db,
      assetPath: 'assets/data/questions.json',
      versionKey: 'questions_seed_version',
      table: 'questions',
    );

    await _seedFromJson(
      db: db,
      assetPath: 'assets/data/concepts.json',
      versionKey: 'concepts_seed_version',
      table: 'concepts',
    );
  }

  Future<void> _seedFromJson({
    required dynamic db,
    required String assetPath,
    required String versionKey,
    required String table,
  }) async {
    try {
      final jsonStr = await rootBundle.loadString(assetPath);
      final data = json.decode(jsonStr) as Map<String, dynamic>;
      final version = data['version'] as int;
      final items = data['items'] as List<dynamic>;

      // Check current seed version
      final existing = await db.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: [versionKey],
      );

      final currentVersion = existing.isNotEmpty
          ? int.tryParse(existing.first['value'] as String) ?? 0
          : 0;

      if (version <= currentVersion) return;

      // Insert new items (INSERT OR IGNORE to skip existing IDs)
      final batch = db.batch();
      for (final item in items) {
        if (item is! Map<String, dynamic>) continue;
        batch.insert(table, item,
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      await batch.commit(noResult: true);

      // Update seed version
      await db.insert(
        'app_settings',
        {'key': versionKey, 'value': version.toString()},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      if (kDebugMode) {
        debugPrint('Seeded $table: ${items.length} items (v$version)');
      }
    } on FormatException catch (e) {
      if (kDebugMode) {
        debugPrint('Seed error ($assetPath): malformed JSON - $e');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Seed error ($assetPath): $e');
      }
    }
  }
}
