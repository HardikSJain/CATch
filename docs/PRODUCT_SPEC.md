# CATch - MVP Product Specification

**Version:** 1.0 (MVP - Week 1-2)  
**Target Build Time:** 20 hours  
**Platform:** Flutter (Android + iOS)  
**Database:** SQLite (local-first, offline)

---

## 1. OVERVIEW

### 1.1 Core Concept
A mobile app that helps CAT aspirants practice questions systematically with:
- Daily minimum targets (breadth across all sections)
- Topic-focused deep practice (depth in one section per day)
- Interactive calendar tracking
- Automatic performance analytics

### 1.2 Key Differentiators
- **Two-tier practice system:** Daily minimum + focused topic
- **Visual progress tracking:** Calendar + streak + heatmap
- **Offline-first:** All data local, no internet required
- **Free:** No ads, no paywall (for now)

---

## 2. USER FLOW

### 2.1 First-Time Setup
1. User opens app
2. Welcome screen: "Welcome to CATch"
3. Set weekly schedule:
   - Mon/Thu: Quants
   - Tue/Fri: VARC
   - Wed/Sat: DILR
   - Sun: Mock/Review
4. Set daily targets:
   - Daily minimum: 3 DILR, 5 QA, 3 VARC (default)
   - Focused practice: 30 questions (default)
5. Navigate to Home Screen

### 2.2 Daily Usage Flow
1. User opens app → Home Screen
2. Sees:
   - Today's daily minimum checklist
   - Today's focused section (e.g., "QUANTS")
   - Streak counter
3. Taps "Start Daily Minimum" or "Continue Focused Practice"
4. Solves questions
5. Reviews answers
6. Returns to Home → sees updated progress
7. When daily minimum complete → green checkmark
8. When focused practice complete → day marked complete on calendar

---

## 3. SCREENS & UI SPEC

### Screen 1: Home Screen (Main Dashboard)

**Layout:**
```
┌─────────────────────────────────────┐
│  CATch        [Settings] │
├─────────────────────────────────────┤
│                                     │
│  🔥 14 Day Streak                   │
│  Saturday, March 14, 2026           │
│                                     │
├─────────────────────────────────────┤
│  DAILY MINIMUM (Tier 1)             │
│  ☑ DILR    3/3 questions            │
│  ☐ QA      2/5 questions            │
│  ☐ VARC    0/3 questions            │
│                                     │
│  [Complete Daily Minimum]           │
├─────────────────────────────────────┤
│  TODAY'S FOCUS: QUANTS (Tier 2)     │
│  Current Topic: Number Systems      │
│  Progress: 8/30 questions           │
│                                     │
│  [Continue Practice]                │
├─────────────────────────────────────┤
│  QUICK STATS                        │
│  Today: 11 questions, 72% accuracy  │
│  This Week: 84 questions            │
├─────────────────────────────────────┤
│  [📅 Calendar]  [📊 Stats]          │
└─────────────────────────────────────┘
```

**Components:**
- Header: App name + Settings icon
- Streak counter (large, prominent)
- Daily minimum checklist (3 items with checkboxes)
- Focused practice card (shows current topic + progress)
- Quick stats summary
- Bottom navigation: Calendar, Stats

**Actions:**
- Tap "Complete Daily Minimum" → Practice Screen (daily_min mode)
- Tap "Continue Practice" → Practice Screen (focused mode)
- Tap Calendar → Calendar Screen
- Tap Stats → Stats Screen

---

### Screen 2: Practice Screen

**Layout:**
```
┌─────────────────────────────────────┐
│  ← Number Systems    Question 8/30  │
├─────────────────────────────────────┤
│                                     │
│  [QUESTION IMAGE - if applicable]   │
│                                     │
│  Q: M is a two digit number which   │
│  has the property that the product  │
│  of factorials of its digits is     │
│  greater than sum of factorials     │
│  of its digits. How many values     │
│  of M exist?                        │
│                                     │
│  ○ (a) 56                           │
│  ○ (b) 64                           │
│  ○ (c) 63                           │
│  ○ (d) None of these                │
│                                     │
├─────────────────────────────────────┤
│  [🔖 Bookmark]        [Submit] ───► │
└─────────────────────────────────────┘
```

**After Submit (Review State):**
```
┌─────────────────────────────────────┐
│  ← Number Systems    Question 8/30  │
├─────────────────────────────────────┤
│  ✅ Correct! (or ❌ Incorrect)       │
│                                     │
│  Your answer: (c) 63                │
│  Correct answer: (c) 63             │
│                                     │
│  EXPLANATION:                       │
│  [Explanation text from database]   │
│  [Explanation image - if applicable]│
│                                     │
├─────────────────────────────────────┤
│  [Next Question] ───────────────► │
└─────────────────────────────────────┘
```

**Components:**
- Header: Back button, topic name, question counter
- Question image (if `has_diagram = true`)
- Question text
- Options (radio buttons)
- Bookmark button (save for later review)
- Submit button
- After submit: Result (correct/incorrect), explanation

**Actions:**
- Select option → enable Submit button
- Tap Submit → Show answer + explanation
- Tap Next → Load next question
- Tap Bookmark → Mark question for later review
- Tap Back → Return to Home (save progress)

---

### Screen 3: Calendar Screen

**Layout:**
```
┌─────────────────────────────────────┐
│  ← March 2026                   [>] │
├─────────────────────────────────────┤
│  Mon  Tue  Wed  Thu  Fri  Sat  Sun │
│                       1🟢   2🟢   3⚪ │
│   4🟢   5🟢   6🔴   7🟢   8🟢   9🟢  10🔴│
│  11🟢  12🟢  13🟢  14⚫  15⚪  16⚪  17⚪│
│  18⚪  19⚪  20⚪  21⚪  22⚪  23⚪  24⚪│
│  25⚪  26⚪  27⚪  28⚪  29⚪  30⚪  31⚪│
├─────────────────────────────────────┤
│  🟢 Complete (min + focused)        │
│  🟡 Only daily minimum done         │
│  🔴 Incomplete                      │
│  ⚫ Today                           │
│  ⚪ Future                          │
├─────────────────────────────────────┤
│  Tap any day to view details        │
└─────────────────────────────────────┘
```

**Tap on a day (e.g., March 10):**
```
┌─────────────────────────────────────┐
│  March 10, 2026 (Wednesday)         │
├─────────────────────────────────────┤
│  Daily Minimum: ❌ Incomplete       │
│  - DILR: 2/3                        │
│  - QA: 5/5 ✓                        │
│  - VARC: 1/3                        │
│                                     │
│  Focused Practice: DILR             │
│  - Questions: 12/30                 │
│  - Accuracy: 67%                    │
│                                     │
│  Total: 20 questions, 1h 24min      │
├─────────────────────────────────────┤
│  [Close]                            │
└─────────────────────────────────────┘
```

**Components:**
- Month navigation (< March 2026 >)
- Calendar grid with color-coded days
- Legend explaining colors
- Day detail popup on tap

**Actions:**
- Tap < > → Navigate months
- Tap any past/current day → Show detail popup
- Tap Close → Dismiss popup

---

### Screen 4: Stats Screen

**Layout:**
```
┌─────────────────────────────────────┐
│  ← Statistics                       │
├─────────────────────────────────────┤
│  OVERALL PROGRESS                   │
│  📊 Total Questions: 347            │
│  ✓ Accuracy: 74%                    │
│  ⏱ Time Spent: 42h 18min            │
│  🔥 Current Streak: 14 days         │
│  🏆 Longest Streak: 21 days         │
├─────────────────────────────────────┤
│  SECTION-WISE BREAKDOWN             │
│                                     │
│  DILR:  102 questions  68% 🟡       │
│  ├─ Seating: 45q  72% 🟢           │
│  ├─ Puzzles: 35q  60% 🔴           │
│  └─ Charts: 22q  75% 🟢            │
│                                     │
│  QA:    178 questions  81% 🟢       │
│  ├─ Number Systems: 67q  85% 🟢    │
│  ├─ Geometry: 54q  78% 🟡          │
│  └─ Algebra: 57q  80% 🟢           │
│                                     │
│  VARC:   67 questions  65% 🔴       │
│  ├─ RC: 42q  68% 🟡                │
│  └─ VA: 25q  60% 🔴                │
├─────────────────────────────────────┤
│  WEEKLY TREND                       │
│  [Line graph showing daily accuracy]│
└─────────────────────────────────────┘
```

**Components:**
- Overall stats (total questions, accuracy, time, streaks)
- Section-wise breakdown with expandable topics
- Color coding: 🟢 >80%, 🟡 60-80%, 🔴 <60%
- Weekly trend graph

**Actions:**
- Tap section → Expand to show topics
- Scroll to see all stats

---

### Screen 5: Settings Screen

**Layout:**
```
┌─────────────────────────────────────┐
│  ← Settings                         │
├─────────────────────────────────────┤
│  DAILY TARGETS                      │
│  Daily Minimum DILR:    3 [+] [-]   │
│  Daily Minimum QA:      5 [+] [-]   │
│  Daily Minimum VARC:    3 [+] [-]   │
│  Focused Practice:     30 [+] [-]   │
├─────────────────────────────────────┤
│  WEEKLY SCHEDULE                    │
│  Monday:    Quants       [Edit]     │
│  Tuesday:   VARC         [Edit]     │
│  Wednesday: DILR         [Edit]     │
│  Thursday:  Quants       [Edit]     │
│  Friday:    VARC         [Edit]     │
│  Saturday:  DILR         [Edit]     │
│  Sunday:    Mock/Review  [Edit]     │
├─────────────────────────────────────┤
│  APP PREFERENCES                    │
│  ☑ Show timer during practice       │
│  ☐ Auto-play explanations           │
│  ☑ Haptic feedback                  │
├─────────────────────────────────────┤
│  ABOUT                              │
│  Version: 1.0.0 (MVP)               │
│  Built by Hardik Jain               │
│  [Report Bug] [Send Feedback]       │
└─────────────────────────────────────┘
```

**Components:**
- Daily target adjustment
- Weekly schedule customization
- App preferences (toggles)
- About section

**Actions:**
- Tap +/- → Adjust targets
- Tap Edit → Change day's focus section
- Toggle preferences → Save to local storage

---

## 4. DATABASE SCHEMA

```sql
-- Questions table
CREATE TABLE questions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  section TEXT NOT NULL, -- 'DILR', 'QA', 'VARC'
  subsection TEXT, -- 'LR', 'DI', 'RC', 'VA' (for DILR/VARC breakdown)
  topic TEXT NOT NULL, -- 'Number Systems', 'Seating Arrangement', etc.
  difficulty TEXT, -- 'Easy', 'Medium', 'Hard'
  
  -- Caselet support (for sets)
  caselet_id INTEGER, -- NULL for standalone questions
  question_number INTEGER, -- Position in set or overall
  
  -- Question content
  question_text TEXT NOT NULL,
  question_type TEXT NOT NULL, -- 'MCQ', 'TITA'
  
  -- Image support
  has_diagram BOOLEAN DEFAULT 0,
  diagram_path TEXT, -- 'assets/images/questions/q_123.png'
  
  -- Options (for MCQ)
  option_a TEXT,
  option_b TEXT,
  option_c TEXT,
  option_d TEXT,
  
  -- Answer
  correct_answer TEXT NOT NULL,
  explanation TEXT,
  explanation_image TEXT, -- Optional diagram in explanation
  
  -- Metadata
  source_book TEXT, -- 'Arun Sharma QA 12th Ed'
  source_page INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (caselet_id) REFERENCES caselets(id)
);

-- Caselets table (for DILR, DI, VARC-RC)
CREATE TABLE caselets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  section TEXT NOT NULL, -- 'DILR', 'VARC'
  subsection TEXT, -- 'LR', 'DI', 'RC'
  topic TEXT, -- 'Seating Arrangement', 'Bar Charts', etc.
  
  -- Caselet content
  caselet_text TEXT NOT NULL, -- The passage/scenario
  
  -- Image support (CRITICAL for DI)
  has_visual BOOLEAN DEFAULT 0,
  visual_path TEXT, -- 'assets/images/caselets/c_56.png'
  visual_type TEXT, -- 'bar_chart', 'table', 'seating_diagram'
  
  -- Metadata
  difficulty TEXT,
  source_book TEXT,
  source_page INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User attempts
CREATE TABLE user_attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id INTEGER NOT NULL,
  attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  user_answer TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL,
  time_taken_seconds INTEGER, -- Optional, for timed mode
  attempt_mode TEXT NOT NULL, -- 'daily_min', 'focused', 'timed'
  
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- Daily targets tracking
CREATE TABLE daily_targets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  date DATE NOT NULL UNIQUE, -- '2026-03-14'
  
  -- Daily minimum targets
  dilr_min_target INTEGER DEFAULT 3,
  qa_min_target INTEGER DEFAULT 5,
  varc_min_target INTEGER DEFAULT 3,
  
  -- Daily minimum completed
  dilr_min_completed INTEGER DEFAULT 0,
  qa_min_completed INTEGER DEFAULT 0,
  varc_min_completed INTEGER DEFAULT 0,
  
  -- Focused practice
  focus_section TEXT, -- 'DILR', 'QA', 'VARC'
  focus_topic TEXT, -- Optional specific topic
  focus_target INTEGER DEFAULT 30,
  focus_completed INTEGER DEFAULT 0,
  
  -- Overall
  is_complete BOOLEAN DEFAULT 0, -- True if daily min + focused both done
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Weekly schedule
CREATE TABLE study_schedule (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  day_of_week INTEGER NOT NULL UNIQUE, -- 1=Mon, 2=Tue, ..., 7=Sun
  focus_section TEXT NOT NULL, -- 'DILR', 'QA', 'VARC', 'MOCK', 'REST'
  focus_topic TEXT -- Optional, NULL means "any topic"
);

-- Bookmarks
CREATE TABLE bookmarks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question_id INTEGER NOT NULL,
  bookmarked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  notes TEXT, -- Optional user notes
  
  FOREIGN KEY (question_id) REFERENCES questions(id)
);

-- App settings
CREATE TABLE app_settings (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL
);
```

---

## 5. SEED DATA (MVP - 100 Questions)

### 5.1 Distribution

**Total: 100 questions**

**QA: 40 questions**
- Number Systems: 10 (5 with diagrams)
- Geometry: 10 (8 with diagrams)
- Algebra: 10 (2 with diagrams)
- Arithmetic: 10 (0 diagrams)

**DILR: 30 questions (10 caselets × 3 questions each)**
- LR Seating: 3 caselets (9 questions, all with diagrams)
- LR Puzzles: 2 caselets (6 questions, all with diagrams)
- DI Charts: 3 caselets (9 questions, all with diagrams)
- DI Tables: 2 caselets (6 questions, 0 diagrams - text tables)

**VARC: 30 questions**
- RC: 2 passages × 5 questions = 10 (0 diagrams)
- VA: 20 questions (0 diagrams)

**Total images needed: ~35-40**

### 5.2 Image Creation Process

**This weekend (5 hours):**
1. Open Arun Sharma PDFs
2. For each question with diagram:
   - Screenshot question + diagram
   - Crop to remove page numbers/headers
   - Save as `q_[id].png` (e.g., `q_1.png`, `q_2.png`)
   - Place in `assets/images/questions/`
3. For caselets with visuals:
   - Screenshot entire caselet (text + chart/diagram)
   - Save as `c_[id].png`
   - Place in `assets/images/caselets/`

**Tools:**
- macOS: Cmd+Shift+4 (screenshot selection)
- Windows: Snipping Tool
- Image editor: Preview (Mac) or Paint (Windows) for cropping

---

## 6. FLUTTER PROJECT STRUCTURE

```
cat_prep_tracker/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── question.dart
│   │   ├── caselet.dart
│   │   ├── user_attempt.dart
│   │   └── daily_target.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── practice_screen.dart
│   │   ├── calendar_screen.dart
│   │   ├── stats_screen.dart
│   │   └── settings_screen.dart
│   ├── widgets/
│   │   ├── question_display.dart
│   │   ├── daily_checklist.dart
│   │   ├── calendar_grid.dart
│   │   └── stats_chart.dart
│   ├── services/
│   │   ├── database_service.dart (SQLite wrapper)
│   │   ├── question_service.dart (fetch questions)
│   │   └── stats_service.dart (calculate stats)
│   └── utils/
│       ├── constants.dart
│       └── helpers.dart
├── assets/
│   └── images/
│       ├── questions/
│       │   ├── q_1.png
│       │   ├── q_2.png
│       │   └── ...
│       └── caselets/
│           ├── c_1.png
│           ├── c_2.png
│           └── ...
├── pubspec.yaml
└── README.md
```

---

## 7. TECH STACK

**Frontend:**
- Flutter 3.x
- Dart 3.x

**State Management:**
- Provider (simple, MVP-friendly)
- OR Riverpod (if you prefer)

**Database:**
- sqflite (SQLite for Flutter)

**Dependencies:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.8.3
  provider: ^6.1.1
  intl: ^0.18.1 # Date formatting
  fl_chart: ^0.65.0 # For stats charts
```

**Assets:**
```yaml
flutter:
  assets:
    - assets/images/questions/
    - assets/images/caselets/
```

---

## 8. MVP DEVELOPMENT PHASES

### Phase 1: Core Structure (4-6 hours)
- [ ] Create Flutter project
- [ ] Set up folder structure
- [ ] Create database schema
- [ ] Create models (Question, Caselet, UserAttempt, DailyTarget)
- [ ] Set up DatabaseService

### Phase 2: Seed Data (5 hours)
- [ ] Screenshot 40 images from PDFs
- [ ] Manually enter 100 questions into database
- [ ] Test data loading

### Phase 3: Home Screen (3 hours)
- [ ] Build Home UI
- [ ] Display daily checklist
- [ ] Display focused practice card
- [ ] Show streak counter

### Phase 4: Practice Screen (4 hours)
- [ ] Build question display
- [ ] Handle MCQ/TITA input
- [ ] Show images (if applicable)
- [ ] Submit answer → show result
- [ ] Navigate to next question

### Phase 5: Calendar & Stats (3 hours)
- [ ] Build calendar grid
- [ ] Color-code days based on completion
- [ ] Build stats screen (basic)

### Phase 6: Testing & Polish (2 hours)
- [ ] Test complete flow (daily min → focused practice)
- [ ] Fix bugs
- [ ] Polish UI

**Total: ~22 hours**

---

## 9. SUCCESS METRICS (MVP)

**By end of Week 2:**
- [ ] App runs on your phone
- [ ] 100 questions loaded and working
- [ ] You can complete daily minimum (11 questions)
- [ ] You can do focused practice (30 questions)
- [ ] Calendar shows your progress
- [ ] Stats show accuracy per section

**By Week 4 (Post-MVP):**
- [ ] You've used it daily for 2 weeks (14-day streak)
- [ ] 200+ total questions in database
- [ ] Shared with 5-10 friends for feedback

---

## 10. NEXT STEPS (This Weekend)

**Saturday (Today):**
1. Create Flutter project
2. Set up database schema
3. Create models
4. Build DatabaseService

**Sunday:**
1. Screenshot 40 images from PDFs
2. Manually seed 50 questions
3. Build Home Screen UI
4. Build Practice Screen UI

**Next Weekend (March 21-22):**
1. Complete remaining 50 questions
2. Build Calendar Screen
3. Build Stats Screen
4. Test end-to-end flow

**Launch:** March 31 (Week 3)

---

## 11. OPEN QUESTIONS

1. **Timer during practice?** Should questions be timed by default?
   - Recommendation: Add toggle in Settings, default OFF for MVP

2. **Explanation format?** Text-only or support images?
   - Recommendation: Support both (some geometry explanations need diagrams)

3. **Difficulty assignment?** Who decides Easy/Medium/Hard?
   - Recommendation: You manually tag during data entry (based on Arun Sharma)

4. **Topic granularity?** How specific should topics be?
   - Recommendation: 2 levels: Section (QA) → Topic (Number Systems)

---

## 12. OUT OF SCOPE (V2+)

- [ ] Mock test mode (full 40-min section)
- [ ] Spaced repetition
- [ ] Peer comparison / leaderboard
- [ ] Cloud sync
- [ ] AI-powered recommendations
- [ ] CAT PYQ database (beyond Arun Sharma)
- [ ] PDF viewer inside app

---

**END OF SPEC**

Next: Feed this to Claude Code and start building!
