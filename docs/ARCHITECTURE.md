# CATch - Technical Architecture

## System Overview

```
┌─────────────────────────────────────────────┐
│           Flutter Mobile App                │
│  (Android + iOS, offline-first)             │
├─────────────────────────────────────────────┤
│  Presentation Layer (UI)                    │
│  ├─ Home Screen                             │
│  ├─ Practice Screen                         │
│  ├─ Calendar Screen                         │
│  ├─ Stats Screen                            │
│  └─ Settings Screen                         │
├─────────────────────────────────────────────┤
│  Business Logic Layer                       │
│  ├─ Provider (State Management)             │
│  ├─ Services (QuestionService, StatsService)│
│  └─ Models (Question, Caselet, UserAttempt) │
├─────────────────────────────────────────────┤
│  Data Layer                                 │
│  ├─ SQLite Database (local)                 │
│  ├─ DatabaseService (CRUD operations)       │
│  └─ Assets (images: questions, caselets)    │
└─────────────────────────────────────────────┘
```

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart 3.x
- **State Management:** Provider
- **UI Components:** Material Design

### Database
- **Local Storage:** SQLite (via sqflite package)
- **Schema:** See DATABASE_SCHEMA.md

### Charts
- **Library:** fl_chart
- **Use:** Stats dashboard (line graphs, pie charts)

### No Backend (MVP)
- All data stored locally
- No internet required
- No user authentication (single-user app)

---

## Data Flow

### Question Practice Flow

```
User taps "Start Practice"
    ↓
QuestionService.getNextQuestion(section, mode)
    ↓
DatabaseService.query(questions table)
    ↓
Return Question object
    ↓
PracticeScreen displays question
    ↓
User selects answer + taps Submit
    ↓
QuestionService.submitAnswer(questionId, userAnswer)
    ↓
DatabaseService.insert(user_attempts table)
    ↓
Update daily_targets (increment completed)
    ↓
Show result (correct/incorrect + explanation)
    ↓
Navigate to next question
```

### Stats Calculation Flow

```
User opens Stats Screen
    ↓
StatsService.calculateStats()
    ↓
DatabaseService.query(user_attempts + questions)
    ↓
Aggregate:
  - Total attempts
  - Accuracy per section
  - Accuracy per topic
  - Weak areas (accuracy < 60%)
    ↓
Return StatsData object
    ↓
StatsScreen renders charts
```

---

## Database Schema

See `DATABASE_SEED_TEMPLATE.md` for complete schema.

### Core Tables:

**1. questions**
- Stores individual questions (MCQ, TITA)
- Links to caselets (for DILR/DI/RC)
- Supports images (diagram_path)

**2. caselets**
- Stores passage/scenario for question sets
- Supports images (visual_path for charts/diagrams)

**3. user_attempts**
- Tracks every question attempt
- Stores answer, correctness, time taken
- Links to questions table

**4. daily_targets**
- Tracks daily progress
- Daily minimum (DILR, QA, VARC)
- Focused practice (30 questions)

**5. study_schedule**
- Weekly rotation (Mon: QA, Tue: VARC, etc.)
- Customizable

---

## State Management

**Provider Pattern:**

```dart
ChangeNotifierProvider(
  create: (_) => AppState(),
  child: MaterialApp(...),
)

class AppState extends ChangeNotifier {
  DailyTarget? _todayTarget;
  int _streak;
  
  Future<void> loadTodayTarget() async {
    _todayTarget = await DatabaseService().getTodayTarget();
    notifyListeners();
  }
  
  Future<void> submitAnswer(int questionId, String answer) async {
    // Submit to database
    // Update daily target
    notifyListeners();
  }
}
```

**Why Provider:**
- Simple, lightweight
- Built-in to Flutter
- Sufficient for MVP scope

---

## File Structure

```
app/
├── lib/
│   ├── main.dart                  # Entry point
│   │
│   ├── models/                    # Data models
│   │   ├── question.dart
│   │   ├── caselet.dart
│   │   ├── user_attempt.dart
│   │   └── daily_target.dart
│   │
│   ├── screens/                   # UI screens
│   │   ├── home_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── calendar_screen.dart
│   │   ├── stats_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── widgets/                   # Reusable widgets
│   │   ├── question_display.dart
│   │   ├── daily_checklist.dart
│   │   ├── calendar_grid.dart
│   │   └── stats_chart.dart
│   │
│   ├── services/                  # Business logic
│   │   ├── database_service.dart
│   │   ├── question_service.dart
│   │   └── stats_service.dart
│   │
│   └── utils/                     # Helpers
│       ├── constants.dart
│       └── helpers.dart
│
└── assets/                        # Static resources
    └── images/
        ├── questions/             # Question diagrams
        └── caselets/              # Charts, tables, diagrams
```

---

## Offline-First Architecture

**All data is local:**
- Questions stored in SQLite
- Images bundled in app assets
- No network calls
- Works on airplane mode

**Benefits:**
- Fast, instant loading
- No data usage
- Privacy (no data sent to server)
- Works anywhere

**Trade-offs:**
- App size increases with images (~50MB for 1000 questions)
- Updates require app update (for V1)

---

## Future Architecture (V2+)

**Cloud Sync (Optional):**
```
Flutter App (Local)
    ↕ (Sync API)
NestJS Backend
    ↕
PostgreSQL (Cloud)
```

**Features:**
- Sync progress across devices
- Cloud backup
- Multi-user support
- Peer comparison

**Not in MVP scope.**

---

## Performance Considerations

**Database Queries:**
- Index on frequently queried columns (section, topic, date)
- Limit queries to necessary fields
- Use pagination for large result sets

**Image Loading:**
- Lazy load images (only when visible)
- Cache images in memory
- Compress images (50KB avg)

**Memory Management:**
- Dispose providers when not needed
- Clear image cache periodically
- Avoid loading all questions at once

---

## Testing Strategy

**Unit Tests:**
- DatabaseService CRUD operations
- QuestionService logic
- StatsService calculations

**Widget Tests:**
- QuestionDisplay rendering
- Calendar grid logic
- Daily checklist state

**Integration Tests:**
- End-to-end practice flow
- Streak calculation
- Stats aggregation

---

## Deployment

**Android:**
1. Build APK: `flutter build apk`
2. Upload to Play Store (beta)
3. Distribute to beta testers

**iOS:**
1. Build IPA: `flutter build ios`
2. Upload to TestFlight
3. Beta testing via TestFlight

**Release:**
- Semantic versioning (1.0.0, 1.1.0, etc.)
- Changelog in releases
- Play Store + App Store

---

## Security

**MVP (local-only):**
- No authentication needed
- No user data collected
- No network calls

**V2+ (with cloud sync):**
- JWT authentication
- E2E encryption for user data
- HTTPS only
- Privacy policy required

---

**End of Architecture Doc**
