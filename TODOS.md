# CATch — TODOS

## P1 — High Priority

### TITA (Type In The Answer) Question Support
**What:** Render a text input field instead of MCQ options when `questionType == 'TITA'`. Handle numeric answer comparison.
**Why:** CAT has ~30% TITA questions. Without this, a major question category is unsupported. TITA has no negative marking, which affects strategy.
**Effort:** M (~1.5 hours)
**Depends on:** Practice screen BLoC refactor.
**Where to start:** In PracticeScreen, check `question.questionType`. If TITA, show a `TextField` with numeric keyboard instead of option buttons. Answer comparison: trim whitespace, parse both as `double`, compare with tolerance (e.g., `(a - b).abs() < 0.001`).

### Full Mock Test Engine
**What:** Full CAT simulation — 3 slots (VARC, DILR, QA), 40 min each, 22-22-22 questions, IIM-style scoring (+3/-1 MCQ, no negative TITA), sectional cutoffs.
**Why:** Nothing else simulates real exam pressure and timing. This is the highest-value feature for CAT readiness.
**Effort:** XL (~8 hours)
**Blocked by:** Need 500+ total questions across all sections (currently 33).
**Where to start:** Add a `mock_tests` table (test_id, created_at, slot_order, total_score, sectional_scores JSON). Create a MockTestBLoC that generates a test by sampling questions proportionally from each section. Build a dedicated mock test UI with section navigation and slot timer.

---

## P2 — Medium Priority

### Topic Mastery Progress Bars
**What:** Show each topic with a visual mastery level (Beginner 0-40% / Familiar 40-65% / Proficient 65-85% / Mastered 85%+) on the analytics screen.
**Why:** Visual feedback motivates continued practice on weak topics. Makes grinding feel like leveling up.
**Effort:** S (~30 min)
**Depends on:** Analytics screen + user_attempts accuracy data.
**Where to start:** Query `SELECT topic, AVG(CASE WHEN is_correct THEN 1.0 ELSE 0.0 END) as accuracy FROM user_attempts GROUP BY topic`. Map accuracy to mastery level. Render as colored progress bars.

### Bookmark Questions
**What:** Let users bookmark questions they want to revisit. Star icon on practice screen, 'Bookmarked' filter in question selection.
**Why:** Users naturally want to flag tricky questions; complements the 'retry missed' feature.
**Effort:** S (~45 min)
**Depends on:** Practice screen, user_attempts table (add `is_bookmarked` boolean).
**Where to start:** Add `is_bookmarked INTEGER DEFAULT 0` to user_attempts. Add star icon to practice screen header. Add 'Bookmarked' practice mode that filters by bookmarked questions.

### Backend + Cloud Sync (NestJS)
**What:** Backend API with user accounts, cloud storage for questions and progress, multi-device sync.
**Why:** Enables multi-device use, shared question banks, study groups, data backup. Future-proofs the app.
**Effort:** XL (~40 hours)
**Depends on:** Stable local app with Repository pattern (ready — just swap LocalRepo for RemoteRepo via get_it).
**Tech:** NestJS + PostgreSQL + JWT auth. REST API mirroring local repository interface.
**Where to start:** Define API contract matching repository interfaces. Build auth flow first. Implement question sync, then progress sync. Add offline-first conflict resolution.

---

## P3 — Nice to Have

### Share Stats Card
**What:** Generate a shareable image of weekly progress (questions solved, accuracy, streak) for social accountability.
**Why:** Social accountability boosts consistency; study groups can compare progress.
**Effort:** M (~2 hours)
**Note:** Approved for build-now in current cycle.

---

## Completed / In Progress
- [x] BLoC + Repository + get_it architecture (decided, pending implementation)
- [x] go_router navigation (decided, pending implementation)
- [x] JSON seed files for questions (decided, pending implementation)
- [x] question_sets table for DILR caselets (decided, pending implementation)
- [x] Incremental DB migrations (decided, pending implementation)
