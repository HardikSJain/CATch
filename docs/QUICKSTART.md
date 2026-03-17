# CATch - Quick Start Guide

**Build your MVP this weekend!**

---

## TONIGHT (Saturday, 2-3 hours)

### Step 1: Create Flutter Project (15 min)

```bash
# Create project
flutter create cat_prep_tracker
cd cat_prep_tracker

# Test it works
flutter run
```

### Step 2: Add Dependencies (5 min)

Edit `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  provider: ^6.1.1
  intl: ^0.18.1
  fl_chart: ^0.65.0

flutter:
  assets:
    - assets/images/questions/
    - assets/images/caselets/
```

Run: `flutter pub get`

### Step 3: Create Folder Structure (5 min)

```bash
mkdir -p lib/models
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/services
mkdir -p lib/utils
mkdir -p assets/images/questions
mkdir -p assets/images/caselets
```

### Step 4: Create Database Service (60 min)

Create `lib/services/database_service.dart`:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'cat_prep.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Caselets table
    await db.execute('''
      CREATE TABLE caselets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section TEXT NOT NULL,
        subsection TEXT,
        topic TEXT,
        caselet_text TEXT NOT NULL,
        has_visual INTEGER DEFAULT 0,
        visual_path TEXT,
        visual_type TEXT,
        difficulty TEXT,
        source_book TEXT,
        source_page INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Questions table
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        section TEXT NOT NULL,
        subsection TEXT,
        topic TEXT NOT NULL,
        difficulty TEXT,
        caselet_id INTEGER,
        question_number INTEGER,
        question_text TEXT NOT NULL,
        question_type TEXT NOT NULL,
        has_diagram INTEGER DEFAULT 0,
        diagram_path TEXT,
        option_a TEXT,
        option_b TEXT,
        option_c TEXT,
        option_d TEXT,
        correct_answer TEXT NOT NULL,
        explanation TEXT,
        explanation_image TEXT,
        source_book TEXT,
        source_page INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (caselet_id) REFERENCES caselets(id)
      )
    ''');
    
    // User attempts table
    await db.execute('''
      CREATE TABLE user_attempts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        attempted_at TEXT DEFAULT CURRENT_TIMESTAMP,
        user_answer TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        time_taken_seconds INTEGER,
        attempt_mode TEXT NOT NULL,
        FOREIGN KEY (question_id) REFERENCES questions(id)
      )
    ''');
    
    // Daily targets table
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
        is_complete INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    
    // Study schedule table
    await db.execute('''
      CREATE TABLE study_schedule (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week INTEGER NOT NULL UNIQUE,
        focus_section TEXT NOT NULL,
        focus_topic TEXT
      )
    ''');
    
    // Seed default schedule
    await db.execute('''
      INSERT INTO study_schedule (day_of_week, focus_section) VALUES
      (1, 'QA'),
      (2, 'VARC'),
      (3, 'DILR'),
      (4, 'QA'),
      (5, 'VARC'),
      (6, 'DILR'),
      (7, 'MOCK')
    ''');
    
    print('Database created successfully!');
  }
  
  // Helper: Get today's date as string
  String getTodayDate() {
    DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
  
  // Get or create today's target
  Future<Map<String, dynamic>> getTodayTarget() async {
    final db = await database;
    String today = getTodayDate();
    
    List<Map<String, dynamic>> results = await db.query(
      'daily_targets',
      where: 'date = ?',
      whereArgs: [today],
    );
    
    if (results.isEmpty) {
      // Create today's target
      int dayOfWeek = DateTime.now().weekday; // 1=Mon, 7=Sun
      
      // Get focus section from schedule
      List<Map<String, dynamic>> schedule = await db.query(
        'study_schedule',
        where: 'day_of_week = ?',
        whereArgs: [dayOfWeek],
      );
      
      String focusSection = schedule.isNotEmpty ? schedule[0]['focus_section'] : 'QA';
      
      await db.insert('daily_targets', {
        'date': today,
        'focus_section': focusSection,
      });
      
      return await getTodayTarget(); // Recursive call to get newly created
    }
    
    return results[0];
  }
}
```

### Step 5: Create Models (30 min)

Create `lib/models/question.dart`:

```dart
class Question {
  final int id;
  final String section;
  final String? subsection;
  final String topic;
  final String? difficulty;
  final int? caseletId;
  final int? questionNumber;
  final String questionText;
  final String questionType;
  final bool hasDiagram;
  final String? diagramPath;
  final String? optionA;
  final String? optionB;
  final String? optionC;
  final String? optionD;
  final String correctAnswer;
  final String? explanation;
  final String? explanationImage;
  
  Question({
    required this.id,
    required this.section,
    this.subsection,
    required this.topic,
    this.difficulty,
    this.caseletId,
    this.questionNumber,
    required this.questionText,
    required this.questionType,
    this.hasDiagram = false,
    this.diagramPath,
    this.optionA,
    this.optionB,
    this.optionC,
    this.optionD,
    required this.correctAnswer,
    this.explanation,
    this.explanationImage,
  });
  
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'],
      section: map['section'],
      subsection: map['subsection'],
      topic: map['topic'],
      difficulty: map['difficulty'],
      caseletId: map['caselet_id'],
      questionNumber: map['question_number'],
      questionText: map['question_text'],
      questionType: map['question_type'],
      hasDiagram: map['has_diagram'] == 1,
      diagramPath: map['diagram_path'],
      optionA: map['option_a'],
      optionB: map['option_b'],
      optionC: map['option_c'],
      optionD: map['option_d'],
      correctAnswer: map['correct_answer'],
      explanation: map['explanation'],
      explanationImage: map['explanation_image'],
    );
  }
}
```

### Step 6: Test Database (15 min)

Create `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'services/database_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CATch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _db = DatabaseService();
  String _status = 'Initializing...';
  
  @override
  void initState() {
    super.initState();
    _initDatabase();
  }
  
  Future<void> _initDatabase() async {
    try {
      await _db.database;
      var target = await _db.getTodayTarget();
      setState(() {
        _status = 'Database ready!\nToday: ${target['date']}\nFocus: ${target['focus_section']}';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CATch'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text(
            _status,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
```

**Run:** `flutter run`

If you see "Database ready!" → You're done for tonight! ✅

---

## TOMORROW (Sunday, 5-6 hours)

### Step 1: Screenshot Images (2 hours)

1. Open `~/.openclaw/workspace/cat-prep/quant.pdf` page 101
2. Screenshot questions 62-71 (10 questions)
3. For questions with diagrams (e.g., geometry), crop and save
4. Save as: `q_1.png`, `q_2.png`, etc. in `assets/images/questions/`

Repeat for:
- LR.pdf (3 seating caselets) → `c_1.png`, `c_2.png`, `c_3.png`
- DI.pdf (3 chart caselets) → `c_4.png`, `c_5.png`, `c_6.png`

**Target: 30 images total**

### Step 2: Seed 50 Questions (2 hours)

Use `DATABASE_SEED_TEMPLATE.md` to manually type SQL INSERT statements.

Start with:
- 10 QA Number Systems questions
- 1 LR Seating caselet (3 questions)
- 1 DI Chart caselet (3 questions)
- 5 VARC VA questions

**Target: 22 questions to start**

Add to `database_service.dart` `_onCreate()`:

```dart
// After creating tables, seed sample questions
await _seedSampleQuestions(db);
```

```dart
Future<void> _seedSampleQuestions(Database db) async {
  // Insert caselet 1
  await db.insert('caselets', {
    'section': 'DILR',
    'subsection': 'LR',
    'topic': 'Seating Arrangement',
    'caselet_text': '[Paste caselet text]',
    'has_visual': 1,
    'visual_path': 'assets/images/caselets/c_1.png',
    'difficulty': 'Medium',
  });
  
  // Insert questions for caselet 1
  await db.insert('questions', {
    'section': 'DILR',
    'subsection': 'LR',
    'topic': 'Seating Arrangement',
    'caselet_id': 1,
    'question_number': 1,
    'question_text': '[Question text]',
    'question_type': 'MCQ',
    'option_a': '8',
    'option_b': '9',
    'option_c': '10',
    'option_d': 'Cannot be determined',
    'correct_answer': 'c',
    'explanation': '[Explanation]',
  });
  
  // Continue for more questions...
}
```

### Step 3: Build Home Screen UI (2 hours)

Replace `HomePage` in `main.dart` with actual UI from `PRODUCT_SPEC.md` Screen 1.

**Use this structure:**
```dart
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? _todayTarget;
  int _streak = 0;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    var target = await DatabaseService().getTodayTarget();
    // Calculate streak
    // Load quick stats
    setState(() {
      _todayTarget = target;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (_todayTarget == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('CATch')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Streak
            _buildStreak(),
            SizedBox(height: 20),
            
            // Daily Minimum
            _buildDailyMinimum(),
            SizedBox(height: 20),
            
            // Focused Practice
            _buildFocusedPractice(),
            SizedBox(height: 20),
            
            // Quick Stats
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStreak() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Text('🔥', style: TextStyle(fontSize: 32)),
            SizedBox(width: 12),
            Text(
              '$_streak Day Streak',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDailyMinimum() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DAILY MINIMUM', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            _buildChecklistItem('DILR', _todayTarget!['dilr_min_completed'], _todayTarget!['dilr_min_target']),
            _buildChecklistItem('QA', _todayTarget!['qa_min_completed'], _todayTarget!['qa_min_target']),
            _buildChecklistItem('VARC', _todayTarget!['varc_min_completed'], _todayTarget!['varc_min_target']),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to practice screen
              },
              child: Text('Complete Daily Minimum'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChecklistItem(String section, int completed, int target) {
    bool isDone = completed >= target;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_box : Icons.check_box_outline_blank,
            color: isDone ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 8),
          Text('$section    $completed/$target questions'),
        ],
      ),
    );
  }
  
  Widget _buildFocusedPractice() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('TODAY\'S FOCUS: ${_todayTarget!['focus_section']}', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Progress: ${_todayTarget!['focus_completed']}/${_todayTarget!['focus_target']} questions'),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Navigate to practice screen
              },
              child: Text('Continue Practice'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUICK STATS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Today: 0 questions, 0% accuracy'),
            Text('This Week: 0 questions'),
          ],
        ),
      ),
    );
  }
}
```

**Run:** `flutter run`

You should now see a proper home screen with your daily targets!

---

## NEXT WEEKEND (March 21-22)

- Build Practice Screen (question display, answer submission)
- Build Calendar Screen
- Build Stats Screen
- Add remaining 50 questions to database

---

## SUCCESS CRITERIA

**By end of Sunday:**
- ✅ App runs on your phone
- ✅ Database created with 22+ questions
- ✅ Home screen shows daily targets
- ✅ You can see today's focus section
- ✅ 30+ images saved and referenced

**You're on track for Week 3 launch!**

---

**Questions? Issues? DM me (Jarvis) on Telegram and I'll help debug.**

Good luck! 🚀
