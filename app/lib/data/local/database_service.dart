import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Owns the SQLite connection and schema migrations.
///
/// Migration chain:
/// ```
/// v1-v3 (legacy) ──destructive──► v4 (clean slate)
///                                  │
///                                  ├── question_sets table
///                                  ├── concept_reviews table
///                                  ├── app_settings table
///                                  ├── UNIQUE(question_id) on user_attempts
///                                  └── 5 indexes
///                                  │
///                          v5+ ────┘ (incremental ALTER TABLE only)
/// ```
class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._();

  DatabaseService._();
  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'catch_app.db');

    return openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Last destructive migration — clean slate for v4
          await db.execute('DROP TABLE IF EXISTS questions');
          await db.execute('DROP TABLE IF EXISTS user_attempts');
          await db.execute('DROP TABLE IF EXISTS daily_targets');
          await db.execute('DROP TABLE IF EXISTS study_schedule');
          await db.execute('DROP TABLE IF EXISTS concepts');
          await db.execute('DROP TABLE IF EXISTS question_sets');
          await db.execute('DROP TABLE IF EXISTS concept_reviews');
          await db.execute('DROP TABLE IF EXISTS app_settings');
          await _createDB(db, newVersion);
        }
        // Future: if (oldVersion < 5) { ALTER TABLE ... }
      },
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY,
        set_id INTEGER,
        section TEXT NOT NULL,
        subsection TEXT,
        topic TEXT NOT NULL,
        difficulty TEXT DEFAULT 'Medium',
        question_text TEXT NOT NULL,
        question_type TEXT DEFAULT 'MCQ',
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        option_e TEXT,
        correct_answer TEXT NOT NULL,
        explanation TEXT,
        image_path TEXT,
        explanation_image_path TEXT,
        source_book TEXT,
        source_page INTEGER,
        FOREIGN KEY (set_id) REFERENCES question_sets(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE question_sets (
        id INTEGER PRIMARY KEY,
        section TEXT NOT NULL,
        subsection TEXT,
        topic TEXT NOT NULL,
        set_type TEXT NOT NULL DEFAULT 'caselet',
        passage_text TEXT,
        passage_image_path TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE user_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL UNIQUE,
        attempted_at TEXT DEFAULT (datetime('now')),
        user_answer TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        attempt_mode TEXT NOT NULL,
        time_taken_seconds INTEGER,
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_targets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        dilr_min_target INTEGER DEFAULT 3,
        qa_min_target INTEGER DEFAULT 5,
        varc_min_target INTEGER DEFAULT 3,
        dilr_min_completed INTEGER DEFAULT 0,
        qa_min_completed INTEGER DEFAULT 0,
        varc_min_completed INTEGER DEFAULT 0,
        focus_section TEXT,
        focus_topic TEXT,
        focus_target INTEGER DEFAULT 30,
        focus_completed INTEGER DEFAULT 0,
        is_complete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE study_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week INTEGER NOT NULL UNIQUE,
        focus_section TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE concepts (
        id INTEGER PRIMARY KEY,
        section TEXT NOT NULL,
        topic TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        sort_order INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE concept_reviews (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        concept_id INTEGER NOT NULL UNIQUE,
        ease_factor REAL DEFAULT 2.5,
        repetitions INTEGER DEFAULT 0,
        interval_days INTEGER DEFAULT 0,
        next_review_date TEXT,
        last_reviewed_at TEXT,
        FOREIGN KEY (concept_id) REFERENCES concepts(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Indexes
    await db.execute(
      'CREATE INDEX idx_attempts_question ON user_attempts(question_id)',
    );
    await db.execute(
      'CREATE INDEX idx_attempts_date ON user_attempts(attempted_at)',
    );
    await db.execute(
      'CREATE INDEX idx_questions_section_topic ON questions(section, topic)',
    );
    await db.execute(
      'CREATE INDEX idx_concept_reviews_date ON concept_reviews(next_review_date)',
    );
    await db.execute(
      'CREATE INDEX idx_daily_targets_date ON daily_targets(date)',
    );

    // Seed default study schedule
    await db.execute('''
      INSERT INTO study_schedule (day_of_week, focus_section) VALUES
      (1, 'QA'), (2, 'VARC'), (3, 'DILR'),
      (4, 'QA'), (5, 'VARC'), (6, 'DILR'), (7, 'MOCK')
    ''');
  }
}
