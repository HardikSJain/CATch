abstract class SettingsRepository {
  /// Get the CAT exam date (nullable if not set).
  Future<DateTime?> getCatExamDate();

  /// Set the CAT exam date.
  Future<void> setCatExamDate(DateTime date);

  /// Get a setting value by key.
  Future<String?> getSetting(String key);

  /// Set a setting value by key.
  Future<void> setSetting(String key, String value);
}
